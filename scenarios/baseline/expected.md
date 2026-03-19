# baseline

Should hit:
- Nothing in the high-risk namespace, capability, seccomp, or mount propagation rule set.

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- `seccomp == unconfined`
- mount propagation contains `shared:X`
- parent mount is `ro` while a child mount under the same subtree is `rw`

