# container-risk-labs

`container-risk-labs` is a local, defensive lab repository for validating a container runtime risk detector against a small set of intentionally risky runtime configurations.
The repository focuses on ordinary images plus high-risk runtime flags rather than malicious image contents.

## Scope and safety boundary

Use this repository only inside a local, isolated, disposable Linux VM.
Do not expose these containers to untrusted networks.
Do not reuse these Compose files in production environments.

This lab does not include exploit code, reverse shells, persistence logic, or external command-and-control behavior.
The goal is to create host-observable runtime signals that a detector should flag.

## Requirements

- Linux host or Linux VM with Docker Engine
- Docker Compose v2 preferred, `docker-compose` v1 accepted as a fallback
- shell access with `sudo` for the shared mount preparation scripts
- native Linux mounts and propagation support

Recommended environment:
- a disposable VM
- rootful Docker Engine

Known limitations:
- `shared-mount` depends on Linux bind mounts and propagation flags; it is not suitable for Docker Desktop on macOS or Windows
- `shared-mount` may also fail under rootless Docker because mount propagation and host bind behavior are restricted
- the repository does not include a host mount namespace sharing scenario because Docker Compose does not expose a clean one-flag equivalent

The `Makefile` prefers `docker compose` and falls back to `docker-compose` automatically when only the legacy binary is available.

## Repository layout

```text
container-risk-labs/
├── README.md
├── Makefile
├── .gitignore
├── base/
│   └── Dockerfile
├── scripts/
│   ├── prepare-shared-mount-host.sh
│   ├── cleanup-shared-mount-host.sh
│   ├── prepare-ro-parent-rw-child.sh
│   └── cleanup-ro-parent-rw-child.sh
├── scenarios/
│   ├── baseline/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── host-pidns/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-admin/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── seccomp-unconfined/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── shared-mount/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   └── ro-parent-rw-child/
│       ├── docker-compose.yml
│       └── expected.md
└── docs/
    └── design-notes.md
```

## Base image

All scenarios reuse one minimal toolbox image built from `debian:stable-slim`.
Installed packages:
- `bash`
- `coreutils`
- `iproute2`
- `libcap2-bin`
- `procps`
- `util-linux`

The image default command is `sleep infinity` so containers stay alive for host-side scanning.

## Scenarios

### 1. baseline

Purpose:
- low-risk control container

Expected detector result:
- no hit for host PID namespace sharing
- no hit for host mount namespace sharing
- no hit for high-risk capabilities
- no hit for unconfined seccomp
- no hit for shared propagation
- no hit for read-only parent with writable child override

Start:

```bash
make build
make up SCENARIO=baseline
```

Stop:

```bash
make down SCENARIO=baseline
```

### 2. host-pidns

Purpose:
- container joins the host PID namespace

Expected detector result:
- hit `pidns == host pidns`
- classify as at least high severity

Start:

```bash
make build
make up SCENARIO=host-pidns
```

Stop:

```bash
make down SCENARIO=host-pidns
```

### 3. cap-sys-admin

Purpose:
- container gets `CAP_SYS_ADMIN`

Expected detector result:
- hit `CAP_SYS_ADMIN` in `CapEff` or `CapPrm`
- classify as high severity

Start:

```bash
make build
make up SCENARIO=cap-sys-admin
```

Stop:

```bash
make down SCENARIO=cap-sys-admin
```

### 4. seccomp-unconfined

Purpose:
- container disables seccomp filtering

Expected detector result:
- hit `seccomp == unconfined`

Notes:
- Docker default behavior is a filtered seccomp profile, not fully disabled seccomp
- this scenario explicitly uses `security_opt: [seccomp=unconfined]`
- a detector can distinguish these states by inspecting seccomp mode from the host
- a common signal is `/proc/<pid>/status`: Docker default filtered seccomp is typically `Seccomp: 2`, while `unconfined` typically results in `Seccomp: 0`

Start:

```bash
make build
make up SCENARIO=seccomp-unconfined
```

Stop:

```bash
make down SCENARIO=seccomp-unconfined
```

### 5. shared-mount

Purpose:
- make a shared propagation marker visible inside container `mountinfo`

Expected detector result:
- hit an optional `mountinfo` field such as `shared:402`

Host preparation:

```bash
sudo ./scripts/prepare-shared-mount-host.sh
```

Start order:

```bash
make build
make up SCENARIO=shared-mount
```

Suggested validation:

```bash
docker exec crl-shared-mount findmnt -o TARGET,PROPAGATION /lab/shared-mount
docker exec crl-shared-mount grep '/lab/shared-mount' /proc/self/mountinfo
```

Stop and cleanup order:

```bash
make down SCENARIO=shared-mount
sudo ./scripts/cleanup-shared-mount-host.sh
```

### 6. ro-parent-rw-child

Purpose:
- create a nested mount where the parent is read-only but a child mount below it is writable

Expected detector result:
- hit a rule for read-only parent with writable child override

Host preparation:

```bash
./scripts/prepare-ro-parent-rw-child.sh
```

Start order:

```bash
make build
make up SCENARIO=ro-parent-rw-child
```

Suggested validation:

```bash
docker exec crl-ro-parent-rw-child grep '/lab/overlay-parent' /proc/self/mountinfo
docker exec crl-ro-parent-rw-child sh -c 'touch /lab/overlay-parent/test-write 2>/dev/null || true'
docker exec crl-ro-parent-rw-child sh -c 'touch /lab/overlay-parent/writable-child/test-write'
```

Stop and cleanup order:

```bash
make down SCENARIO=ro-parent-rw-child
./scripts/cleanup-ro-parent-rw-child.sh
```

## Fastest usage path

```bash
make build
make up SCENARIO=baseline
make ps
make down SCENARIO=baseline
```

Examples for the two scenarios with host preparation:

```bash
sudo ./scripts/prepare-shared-mount-host.sh
make up SCENARIO=shared-mount
make down SCENARIO=shared-mount
sudo ./scripts/cleanup-shared-mount-host.sh
```

```bash
./scripts/prepare-ro-parent-rw-child.sh
make up SCENARIO=ro-parent-rw-child
make down SCENARIO=ro-parent-rw-child
./scripts/cleanup-ro-parent-rw-child.sh
```

## Make targets

- `make build`
- `make up SCENARIO=baseline`
- `make down SCENARIO=baseline`
- `make prepare-shared`
- `make cleanup-shared`
- `make prepare-ro-rw`
- `make cleanup-ro-rw`
- `make ps`

## Expected detector outputs by scenario

- `baseline`: no high-risk hits from the rule families covered in this repository
- `host-pidns`: host PID namespace sharing
- `cap-sys-admin`: `CAP_SYS_ADMIN` in effective or permitted capabilities
- `seccomp-unconfined`: seccomp disabled or unconfined
- `shared-mount`: `shared:X` mount propagation marker in `mountinfo`
- `ro-parent-rw-child`: read-only parent mount with a writable child mount override

Each scenario directory also includes an `expected.md` file with a concise allowlist and denylist for validation.

## Cleanup

Stop a scenario:

```bash
make down SCENARIO=<name>
```

List lab containers:

```bash
make ps
```

Clean host artifacts:

```bash
sudo ./scripts/cleanup-shared-mount-host.sh
./scripts/cleanup-ro-parent-rw-child.sh
```

## Notes

- Containers are intentionally kept alive so a host-side detector can inspect them
- `shared-mount` is the most environment-sensitive scenario because it depends on host mount propagation semantics
- `cap-sys-admin` is intentionally isolated from other high-risk knobs by dropping all other capabilities first
- `host-pidns` shares only the PID namespace; it does not deliberately share the host mount namespace

## Do not use this in production

These configurations are intentionally risky.
Do not deploy them outside a local disposable lab.
Do not publish the containers on public interfaces or expose their ports externally.
