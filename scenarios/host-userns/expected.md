# host-userns

Purpose:
- validate the single-rule `Fatal` namespace finding `Thread shares the host user namespace`
- show that container root keeps host-meaning UID/GID semantics on a controlled host bind mount

Should hit:
- `Thread shares the host user namespace`

Should not hit:
- `Thread shares the host PID namespace`
- `Thread runs without seccomp filtering`

Suggested validation:

```bash
make prepare-host-userns
make up SCENARIO=host-userns
../bin/runtia --container-id crl-host-userns
./scripts/prove-host-userns-ownership.sh
make down SCENARIO=host-userns
make cleanup-host-userns
```

Case-study note:
- container root creates a file in a controlled host bind mount
- the host observes that file as owned by host `0:0`
- this demonstrates that the container is not using remapped or private user-ID semantics
