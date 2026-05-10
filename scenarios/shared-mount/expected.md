# shared-mount

Purpose:
- validate a representative single-rule `HighRisk` mount case
- show that a host-side mount event propagates into the container view through a non-private mount subtree

Should hit:
- mount propagation contains `shared:X`
- warning for shared mount propagation inside the container mount namespace

Should not hit:
- `pidns == host pidns`
- `mntns == host mntns`
- high-risk capability such as `CAP_SYS_ADMIN`
- `seccomp == unconfined`
- parent mount is `ro` while a child mount under the same subtree is `rw`

Suggested validation:

```bash
make prepare-shared
make up SCENARIO=shared-mount
../bin/runtia --container-id crl-shared-mount
./scripts/prove-shared-mount-visibility.sh
make down SCENARIO=shared-mount
make cleanup-shared
```

Case-study note:
- the container itself does not get `CAP_SYS_ADMIN`
- the proof action is performed on a controlled host subtree only
- successful visibility of the new host mount inside the container shows that mount events are no longer contained to one side of the boundary, which is why the rule is `HighRisk`
