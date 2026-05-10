# writable-host-mount

Purpose:
- validate the single-rule `HighRisk` mount finding `Host filesystem view /host is writable`
- show that an ordinary write from inside the container reaches a controlled host bind mount

Should hit:
- `Host filesystem view /host is writable`

Should not hit:
- `Thread shares the host PID namespace`
- `Thread runs without seccomp filtering`

Suggested validation:

```bash
make prepare-host-writable
make up SCENARIO=writable-host-mount
../bin/runtia --container-id crl-writable-host-mount
./scripts/prove-writable-host-mount.sh
make down SCENARIO=writable-host-mount
make cleanup-host-writable
```

Case-study note:
- the host prepares a writable bind source with a marker file
- the container appends a line to that marker file through `/host`
- the host observes the new line immediately, which is why the detector keeps this path as `HighRisk`
