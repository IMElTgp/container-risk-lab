# cap-sys-admin

Purpose:
- validate a representative single-rule `Fatal` capability case
- use a controlled tmpfs mount inside the container as a safe proof action

Should hit:
- single-rule `Fatal` capability finding for `CAP_SYS_ADMIN`
- `CapEff` or `CapPrm` includes the `CAP_SYS_ADMIN` bit

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- `seccomp == unconfined`
- mount propagation contains `shared:X`
- parent mount is `ro` while a child mount under the same subtree is `rw`

Suggested validation:

```bash
make up SCENARIO=cap-sys-admin
../bin/runtia --container-id crl-cap-sys-admin
./scripts/prove-cap-sys-admin-mount.sh
make down SCENARIO=cap-sys-admin
```

Case-study note:
- the proof action is intentionally limited to mounting `tmpfs` at a disposable directory inside the container
- successful mount is not the maximum impact of `CAP_SYS_ADMIN`; it is a safe proxy proving that the thread already holds a capability that gates broad mount and namespace operations
- this supports `Fatal` in the current codebase because the capability is a gateway to many privileged kernel-facing operations rather than a narrow application permission
