# shared-mount

Should hit:
- mount propagation contains `shared:X`
- warning for shared mount propagation inside the container mount namespace

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- `seccomp == unconfined`
- parent mount is `ro` while a child mount under the same subtree is `rw`

