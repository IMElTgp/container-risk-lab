# host-pidns

Purpose:
- validate a representative single-rule `HighRisk` namespace case
- use a controlled host `sleep` process as a non-destructive visibility probe

Should hit:
- `pidns == host pidns`
- high severity finding for host PID namespace sharing

Should not hit:
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- `seccomp == unconfined`
- mount propagation contains `shared:X`
- parent mount is `ro` while a child mount under the same subtree is `rw`

Suggested validation:

```bash
make prepare-host-pidns
make up SCENARIO=host-pidns
../bin/runtia --container-id crl-host-pidns
./scripts/prove-host-pidns-visibility.sh
make down SCENARIO=host-pidns
make cleanup-host-pidns
```

Case-study note:
- the container does not get host-process control capabilities such as `CAP_KILL` or `CAP_SYS_PTRACE`
- the proof only demonstrates visibility: the container can observe a controlled host process through `/proc` and `ps`
- this supports `HighRisk` rather than `Fatal` because process isolation is clearly weakened, but direct host-process control still depends on extra permissions or additional risky conditions
