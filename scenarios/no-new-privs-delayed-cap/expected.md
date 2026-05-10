# no-new-privs-delayed-cap

Purpose:
- validate the composition rule `NoNewPrivs disabled + delayed privilege-transition capability`
- show that a process can rest with `CAP_SETUID` outside `CapEff`, then regain it after a controlled `execve`

Should hit:
- `Thread does not enable no_new_privs`
- `Thread has CAP_SETUID in its permitted capability set`
- composition finding: `NoNewPrivs disabled combined with delayed privilege-transition capability`

Should not hit:
- `Thread shares the host PID namespace`
- `Thread runs without seccomp filtering`
- `Host filesystem view /host is writable`

Suggested validation:

```bash
make prepare-delayed-cap
make up SCENARIO=no-new-privs-delayed-cap
../bin/runtia --container-id crl-no-new-privs-delayed-cap
./scripts/prove-no-new-privs-delayed-cap.sh
make down SCENARIO=no-new-privs-delayed-cap
make cleanup-delayed-cap
```

Case-study note:
- the process is scanned while `CAP_SETUID` is absent from `CapEff` but still present in later privilege-transition sets
- after a controlled `execve`, the same process regains `CAP_SETUID` in `CapEff`
- this is why `NoNewPrivs=false` is not just an informational oddity when combined with delayed privilege-transition capabilities
