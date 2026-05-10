# container-risk-labs

`container-risk-labs` is a local, defensive lab repository for validating a container runtime risk detector against a small set of intentionally risky runtime configurations.
The repository focuses on ordinary images plus high-risk runtime flags rather than malicious image contents.

## Scope and safety boundary

Use this repository only inside a local, isolated, disposable Linux VM.
Do not expose these containers to untrusted networks.
Do not reuse these Compose files in production environments.

This lab does not include exploit code, reverse shells, persistence logic, or external command-and-control behavior.
The goal is to create host-observable runtime signals that a detector should flag.

These scenarios now validate both detection correctness and selected controlled case studies. The current documentation distinguishes three outcomes: the detector hit and the probe succeeded, the detector hit but the chosen probe was blocked by host hardening, or the scenario still needs another environment for follow-up validation.

## Proof safety gate

Before adding any new proof helper, use this gate:

1. statically decide whether the action touches only container-local state or a controlled host asset
2. dry-run the action in a one-shot container before promoting it to a scenario
3. check whether the relevant subsystem is isolated from the host before running the full proof
4. reject the proof if it can mutate host-global state without a controlled isolation layer

The following proof targets are out of scope on this host:

- host system time
- host-global sysctl or `/proc/sys` state
- host-global network configuration
- host real device state
- uncontrolled host filesystem paths

On this machine, acceptable proof actions are limited to:

- container-local effects
- writes or actions against pre-created, disposable, controlled host assets

Additional rule:

- if a capability can directly reach the host when isolation is missing, that is strong evidence of the risk itself
- but the proof still must be constrained to a controlled host asset rather than unrestricted host-global state

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
- some mount-based case-study probes may be blocked by host SELinux, LSM, labeling, or other local hardening even when the detector still correctly reports the dangerous combination

The `Makefile` prefers `docker compose` and falls back to `docker-compose` automatically when only the legacy binary is available.

The proof helpers under `./scripts` are intentionally small and local:

- `prove-cap-sys-admin-mount.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-net-raw.sh`: representative `HighRisk` single-rule capability proof
- `prove-cap-net-admin.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-bpf.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-sys-module.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-sys-rawio.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-sys-boot.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-dac-read-search.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-dac-override-single.sh`: representative `Fatal` single-rule capability proof
- `prove-cap-mknod.sh`: representative `HighRisk` single-rule capability proof
- `prove-cap-perfmon.sh`: representative `HighRisk` single-rule capability proof
- `prove-cap-setfcap.sh`: representative `HighRisk` single-rule capability proof
- `prove-cap-setpcap.sh`: representative `HighRisk` single-rule capability proof
- `prove-cap-sys-resource.sh`: representative `HighRisk` single-rule capability proof
- `prove-seccomp-unconfined-syscall-surface.sh`: representative `HighRisk` single-rule seccomp proof
- `prove-host-pidns-visibility.sh`: representative `HighRisk` single-rule namespace proof
- `prove-host-userns-ownership.sh`: representative `Fatal` single-rule namespace proof
- `prove-shared-mount-visibility.sh`: representative `HighRisk` single-rule mount proof
- `prove-writable-host-mount.sh`: representative `HighRisk` single-rule mount proof
- `prove-cap-kill-host-pidns.sh`: representative `composition` proof
- `prove-cap-sys-ptrace-host-pidns.sh`: representative `composition` proof
- `prove-cap-sys-admin-shared-mount.sh`: representative `composition` proof
- `prove-no-new-privs-delayed-cap.sh`: representative `composition` proof
- `prove-cap-sys-chroot-mountns.sh`: representative `composition` proof
- `prove-cap-dac-override-host-mount.sh`: representative `composition` proof with explicit host-hardening classification

## Current validation status

As of 2026-05-10, the following phase-4 outcomes have been reproduced:

- representative single-rule proofs succeeded:
  - `cap-sys-admin`
  - `cap-net-raw`
  - `cap-net-admin`
  - `cap-bpf`
  - `cap-sys-module`
  - `cap-sys-rawio`
  - `cap-sys-boot`
  - `cap-dac-read-search`
  - `cap-dac-override-single`
  - `cap-mknod`
  - `cap-perfmon`
  - `cap-setfcap`
  - `cap-setpcap`
  - `cap-sys-resource`
  - `seccomp-unconfined`
  - `host-pidns`
  - `host-userns`
  - `shared-mount`
  - `writable-host-mount`
- detection plus probe or state validation succeeded:
  - `seccomp-unconfined-cap-sys-admin`
  - `seccomp-unconfined-cap-mknod`
  - `cap-kill-host-pidns`
  - `cap-sys-ptrace-host-pidns`
  - `cap-sys-admin-shared-mount`
  - `no-new-privs-delayed-cap`
  - `cap-sys-chroot-mountns`
- detection succeeded, but the chosen write probe was blocked by host hardening:
  - `cap-dac-override-writable-host-mount`

This split is deliberate. A blocked write probe on a hardened host does not mean the detector over-reported the composition; it means the risky preconditions were present, but the host still had an additional defensive layer.

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
│   ├── cleanup-ro-parent-rw-child.sh
│   ├── prepare-dac-override-host-mount.sh
│   ├── cleanup-dac-override-host-mount.sh
│   ├── prepare-host-pidns-visibility.sh
│   ├── cleanup-host-pidns-visibility.sh
│   ├── prepare-cap-kill-host-pidns.sh
│   ├── cleanup-cap-kill-host-pidns.sh
│   ├── prepare-cap-sys-ptrace-host-pidns.sh
│   ├── cleanup-cap-sys-ptrace-host-pidns.sh
│   ├── prove-cap-sys-admin-mount.sh
│   ├── prove-cap-net-raw.sh
│   ├── prove-cap-net-admin.sh
│   ├── prove-cap-bpf.sh
│   ├── prove-cap-sys-module.sh
│   ├── prove-cap-sys-rawio.sh
│   ├── prove-cap-sys-boot.sh
│   ├── prove-cap-dac-read-search.sh
│   ├── prove-cap-dac-override-single.sh
│   ├── prove-cap-mknod.sh
│   ├── prove-cap-perfmon.sh
│   ├── prove-cap-setfcap.sh
│   ├── prove-cap-setpcap.sh
│   ├── prove-cap-sys-resource.sh
│   ├── prove-seccomp-unconfined-syscall-surface.sh
│   ├── prove-host-pidns-visibility.sh
│   ├── prove-host-userns-ownership.sh
│   ├── prove-shared-mount-visibility.sh
│   ├── prove-writable-host-mount.sh
│   ├── prove-cap-kill-host-pidns.sh
│   ├── prove-cap-sys-ptrace-host-pidns.sh
│   ├── prove-cap-sys-admin-shared-mount.sh
│   ├── prove-no-new-privs-delayed-cap.sh
│   ├── prove-cap-sys-chroot-mountns.sh
│   ├── prove-cap-dac-override-host-mount.sh
│   └── ptrace_attach_probe.go
├── scenarios/
│   ├── baseline/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── host-pidns/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── host-userns/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-admin/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-net-raw/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-net-admin/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-bpf/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-module/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-rawio/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-boot/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-dac-read-search/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-dac-override-single/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-mknod/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-perfmon/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-setfcap/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-setpcap/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-resource/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── seccomp-unconfined/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── shared-mount/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── writable-host-mount/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-dac-override-writable-host-mount/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-kill-host-pidns/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-ptrace-host-pidns/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-admin-shared-mount/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── no-new-privs-delayed-cap/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── cap-sys-chroot-mountns/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── seccomp-unconfined-cap-sys-admin/
│   │   ├── docker-compose.yml
│   │   └── expected.md
│   ├── seccomp-unconfined-cap-mknod/
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

Suggested case-study validation:

```bash
make prepare-host-pidns
./scripts/prove-host-pidns-visibility.sh
```

Stop:

```bash
make down SCENARIO=host-pidns
make cleanup-host-pidns
```

### 3. cap-sys-admin

Purpose:
- container gets `CAP_SYS_ADMIN`

Expected detector result:
- hit `CAP_SYS_ADMIN` in `CapEff` or `CapPrm`
- classify as `Fatal` in the current codebase

Start:

```bash
make build
make up SCENARIO=cap-sys-admin
```

Suggested case-study validation:

```bash
./scripts/prove-cap-sys-admin-mount.sh
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

Suggested case-study validation:

```bash
make up SCENARIO=baseline
BASELINE_CONTAINER=crl-baseline UNCONFINED_CONTAINER=crl-seccomp-unconfined ./scripts/prove-seccomp-unconfined-syscall-surface.sh
make down SCENARIO=baseline
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
make prepare-shared
```

Start order:

```bash
make build
make up SCENARIO=shared-mount
```

Suggested validation:

```bash
./scripts/prove-shared-mount-visibility.sh
```

Stop and cleanup order:

```bash
make down SCENARIO=shared-mount
make cleanup-shared
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

### 7. cap-dac-override-writable-host-mount

Purpose:
- combine `CAP_DAC_OVERRIDE` with a writable `/host` bind mount backed by a controlled host directory

Expected detector result:
- hit the capability finding for `CAP_DAC_OVERRIDE`
- hit the writable host-view mount finding for `/host`
- hit the composition finding `CAP_DAC_OVERRIDE combined with writable host or sensitive mount`

Host preparation:

```bash
make prepare-dac
```

Start:

```bash
make build
make up SCENARIO=cap-dac-override-writable-host-mount
```

Suggested case-study validation:

```bash
./scripts/prove-cap-dac-override-host-mount.sh
```

Validation note:
- on hardened hosts, this direct write probe can fail because of SELinux, labeling, or other LSM policy even when the detector still reports the composition correctly
- treat that outcome as "detection verified, exploit path blocked by host hardening", not as a detector regression

Stop and cleanup:

```bash
make down SCENARIO=cap-dac-override-writable-host-mount
make cleanup-dac
```

### 8. cap-kill-host-pidns

Purpose:
- combine host PID namespace sharing with `CAP_KILL`

Expected detector result:
- hit the host PID namespace finding
- hit the capability finding for `CAP_KILL`
- hit the composition finding `CAP_KILL combined with host PID namespace`

Host preparation:

```bash
make prepare-cap-kill
```

Start:

```bash
make build
make up SCENARIO=cap-kill-host-pidns
```

Suggested case-study validation:

```bash
./scripts/prove-cap-kill-host-pidns.sh
```

Validation note:
- on the current reference environment, this probe succeeded and the controlled host process exited

Stop and cleanup:

```bash
make down SCENARIO=cap-kill-host-pidns
make cleanup-cap-kill
```

### 9. cap-sys-ptrace-host-pidns

Purpose:
- combine host PID namespace sharing with `CAP_SYS_PTRACE`

Expected detector result:
- hit the host PID namespace finding
- hit the capability finding for `CAP_SYS_PTRACE`
- hit the composition finding `CAP_SYS_PTRACE combined with host PID namespace`

Host preparation:

```bash
make prepare-cap-ptrace
```

Start:

```bash
make build
make up SCENARIO=cap-sys-ptrace-host-pidns
```

Suggested case-study validation:

```bash
./scripts/prove-cap-sys-ptrace-host-pidns.sh
```

Validation note:
- on the current reference environment, the probe attached to a controlled host process and detached again
- on other hosts, Yama, SELinux, AppArmor, rootless Docker, or user namespace policy may still block ptrace

Stop and cleanup:

```bash
make down SCENARIO=cap-sys-ptrace-host-pidns
make cleanup-cap-ptrace
```

### 10. cap-sys-admin-shared-mount

Purpose:
- combine `CAP_SYS_ADMIN` with shared mount propagation

Expected detector result:
- hit the `CAP_SYS_ADMIN` finding
- hit the non-private mount propagation finding
- hit the composition finding `CAP_SYS_ADMIN combined with non-private mount propagation`

Host preparation:

```bash
make prepare-shared
```

Start:

```bash
make build
make up SCENARIO=cap-sys-admin-shared-mount
```

Suggested case-study validation:

```bash
./scripts/prove-cap-sys-admin-shared-mount.sh
```

Validation note:
- on the current reference environment, a tmpfs mounted inside the container propagated onto the controlled host shared subtree
- the scenario sets `label=disable` because SELinux labeling can otherwise block the bind subtree writes required to create the mount target

Stop and cleanup:

```bash
make down SCENARIO=cap-sys-admin-shared-mount
make cleanup-shared
```

### 11. seccomp-unconfined-cap-sys-admin

Purpose:
- combine unconfined seccomp with `CAP_SYS_ADMIN`

Expected detector result:
- hit the seccomp-unconfined finding
- hit the `CAP_SYS_ADMIN` finding
- hit the composition finding `Unconfined seccomp combined with high-risk capability`

Start:

```bash
make build
make up SCENARIO=seccomp-unconfined-cap-sys-admin
```

Suggested case-study validation:

```bash
docker exec crl-seccomp-unconfined-cap-sys-admin sh -lc 'grep "^Seccomp:" /proc/self/status && grep "^CapEff:" /proc/self/status'
docker exec crl-seccomp-unconfined-cap-sys-admin sh -lc 'unshare -m true'
```

Validation note:
- the current phase-4 result for this scenario is primarily a state validation: `Seccomp: 0` plus `CAP_SYS_ADMIN` visible in `CapEff`

Stop:

```bash
make down SCENARIO=seccomp-unconfined-cap-sys-admin
```

### 12. seccomp-unconfined-cap-mknod

Purpose:
- combine unconfined seccomp with `CAP_MKNOD`

Expected detector result:
- hit the seccomp-unconfined finding
- hit the `CAP_MKNOD` finding
- hit the composition finding `Unconfined seccomp combined with high-risk capability`

Start:

```bash
make build
make up SCENARIO=seccomp-unconfined-cap-mknod
```

Suggested case-study validation:

```bash
docker exec crl-seccomp-unconfined-cap-mknod sh -lc 'rm -f /tmp/test-null && mknod /tmp/test-null c 1 3 && ls -l /tmp/test-null'
```

Validation note:
- on the current reference environment, `mknod` succeeded and produced the expected device node

Stop:

```bash
make down SCENARIO=seccomp-unconfined-cap-mknod
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
make prepare-shared
make up SCENARIO=shared-mount
make down SCENARIO=shared-mount
make cleanup-shared
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
- `make prepare-dac`
- `make cleanup-dac`
- `make prepare-host-pidns`
- `make cleanup-host-pidns`
- `make prepare-cap-kill`
- `make cleanup-cap-kill`
- `make prepare-cap-ptrace`
- `make cleanup-cap-ptrace`
- `make ps`

## Expected detector outputs by scenario

- `baseline`: no high-risk hits from the rule families covered in this repository
- `host-pidns`: host PID namespace sharing
- `cap-sys-admin`: `CAP_SYS_ADMIN` in effective or permitted capabilities
- `seccomp-unconfined`: seccomp disabled or unconfined
- `shared-mount`: `shared:X` mount propagation marker in `mountinfo`
- `ro-parent-rw-child`: read-only parent mount with a writable child mount override
- `cap-sys-ptrace-host-pidns`: `CAP_SYS_PTRACE` plus host PID namespace composition
- `cap-sys-admin-shared-mount`: `CAP_SYS_ADMIN` plus non-private mount propagation composition

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
./scripts/cleanup-host-pidns-visibility.sh
./scripts/cleanup-cap-kill-host-pidns.sh
```

## Notes

- Containers are intentionally kept alive so a host-side detector can inspect them
- `shared-mount` is the most environment-sensitive scenario because it depends on host mount propagation semantics
- `cap-sys-admin` is intentionally isolated from other high-risk knobs by dropping all other capabilities first
- `host-pidns` shares only the PID namespace; it does not deliberately share the host mount namespace
- the proof helpers target only controlled files, temporary mounts, or disposable host test processes

## Do not use this in production

These configurations are intentionally risky.
Do not deploy them outside a local disposable lab.
Do not publish the containers on public interfaces or expose their ports externally.
