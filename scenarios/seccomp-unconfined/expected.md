# seccomp-unconfined

Should hit:
- `seccomp == unconfined`
- process status shows seccomp disabled, for example `Seccomp: 0` rather than Docker default filtered mode such as `Seccomp: 2`

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- mount propagation contains `shared:X`
- parent mount is `ro` while a child mount under the same subtree is `rw`
