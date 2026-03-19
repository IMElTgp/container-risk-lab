# cap-sys-admin

Should hit:
- high-risk capability: `CAP_SYS_ADMIN`
- `CapEff` or `CapPrm` includes the `CAP_SYS_ADMIN` bit

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- `seccomp == unconfined`
- mount propagation contains `shared:X`
- parent mount is `ro` while a child mount under the same subtree is `rw`

