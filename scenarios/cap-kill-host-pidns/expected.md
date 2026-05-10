# cap-kill-host-pidns

Purpose:
- validate the composition rule `CAP_KILL + host PID namespace`
- use a controlled host `sleep` process owned by the local user

Should hit:
- `Thread has CAP_KILL in its effective capability set`
- `Thread shares the host PID namespace`
- composition finding: `CAP_KILL combined with host PID namespace`

Should not hit:
- `Thread runs without seccomp filtering`
- `Mount point with non-private status in mount tree`
- `Host filesystem view /host is writable`

Suggested validation:

```bash
make prepare-cap-kill
make up SCENARIO=cap-kill-host-pidns
../bin/runtia --container-id crl-cap-kill-host-pidns
./scripts/prove-cap-kill-host-pidns.sh
make down SCENARIO=cap-kill-host-pidns
make cleanup-cap-kill
```

Case-study note:
- the host test process belongs to the local user rather than host root
- the container joins the host PID namespace and gets only `CAP_KILL`
- successful termination of the controlled host process shows why host PID visibility plus signal-bypass capability deserves a `Fatal` composition rating instead of staying at a weaker single-signal severity
