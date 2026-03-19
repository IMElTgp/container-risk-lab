# host-pidns

Should hit:
- `pidns == host pidns`
- high severity finding for host PID namespace sharing

Should not hit:
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- `seccomp == unconfined`
- mount propagation contains `shared:X`
- parent mount is `ro` while a child mount under the same subtree is `rw`

