# cap-sys-chroot-mountns

Purpose:
- validate the composition rule `CAP_SYS_CHROOT + thread-level mount namespace deviation`
- use a helper that creates a non-main thread with a private mount namespace and then drops setup-only capabilities before scanning

Should hit:
- `Thread has CAP_SYS_CHROOT in its effective capability set`
- `Thread uses a different mount namespace than its main thread`
- composition finding: `CAP_SYS_CHROOT combined with thread-level mount namespace deviation`

Should not hit:
- `Thread shares the host PID namespace`
- `Thread runs without seccomp filtering`
- `Host filesystem view /host is writable`

Suggested validation:

```bash
make prepare-cap-chroot
make up SCENARIO=cap-sys-chroot-mountns
../bin/runtia --container-id crl-cap-sys-chroot-mountns
./scripts/prove-cap-sys-chroot-mountns.sh
make down SCENARIO=cap-sys-chroot-mountns
make cleanup-cap-chroot
```

Case-study note:
- the helper uses `CAP_SYS_ADMIN` only during setup to create the private mount namespace and then drops it before the scan point
- the scanned runtime state keeps `CAP_SYS_CHROOT` and the thread-level mount namespace split
- successful `chroot` into a marker root that exists only in the worker thread's private mount namespace shows why the combination is more dangerous than either signal alone
