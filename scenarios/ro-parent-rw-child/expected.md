# ro-parent-rw-child

Should hit:
- parent mount is `ro` while a child mount under the same subtree is `rw`
- nested mount permissions override warning for `/lab/overlay-parent/writable-child`

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- `seccomp == unconfined`
- mount propagation contains `shared:X`

