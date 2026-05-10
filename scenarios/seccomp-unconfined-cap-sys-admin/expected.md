# seccomp-unconfined-cap-sys-admin

Purpose:
- validate the composition rule `seccomp unconfined + high-risk capability`
- use `CAP_SYS_ADMIN` as the high-risk capability

Should hit:
- `Thread runs without seccomp filtering`
- `Thread has CAP_SYS_ADMIN in its effective capability set`
- composition finding: `Unconfined seccomp combined with high-risk capability`

Should not hit:
- `Thread shares the host PID namespace`
- `Host filesystem view /host is writable`
- `Mount point with non-private status in mount tree`

Suggested validation:

```bash
make up SCENARIO=seccomp-unconfined-cap-sys-admin
../bin/runtia --container-id crl-seccomp-unconfined-cap-sys-admin
docker exec crl-seccomp-unconfined-cap-sys-admin sh -lc 'grep "^Seccomp:" /proc/self/status && grep "^CapEff:" /proc/self/status'
docker exec crl-seccomp-unconfined-cap-sys-admin sh -lc 'unshare -m true'
make down SCENARIO=seccomp-unconfined-cap-sys-admin
```

Case-study note:
- `unshare -m` is a representative follow-up action because it needs namespace-related privilege and is commonly blocked by Docker's default seccomp profile
- if the host LSM or runtime policy still blocks `unshare`, record the denial reason; the detection result should still show both primitive findings and the composition finding

