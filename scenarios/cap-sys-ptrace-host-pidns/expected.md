# cap-sys-ptrace-host-pidns

Purpose:
- validate the composition rule `CAP_SYS_PTRACE + host PID namespace`
- use a controlled host `sleep` process and a non-destructive attach/detach probe

Should hit:
- `Thread has CAP_SYS_PTRACE in its effective capability set`
- `Thread shares the host PID namespace`
- composition finding: `CAP_SYS_PTRACE combined with host PID namespace`

Should not hit:
- `Thread runs without seccomp filtering`
- `Host filesystem view /host is writable`
- `Mount point with non-private status in mount tree`

Suggested validation:

```bash
make prepare-cap-ptrace
make up SCENARIO=cap-sys-ptrace-host-pidns
../bin/runtia --container-id crl-cap-sys-ptrace-host-pidns
./scripts/prove-cap-sys-ptrace-host-pidns.sh
make down SCENARIO=cap-sys-ptrace-host-pidns
make cleanup-cap-ptrace
```

Case-study note:
- the probe only attaches to a controlled host process and detaches immediately
- successful attach/detach shows that the container can cross the process boundary and exercise ptrace control over a host-visible process
- this supports a `Fatal` composition rating because host PID visibility plus ptrace control is substantially stronger than either signal alone
