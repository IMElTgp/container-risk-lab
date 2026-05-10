# cap-sys-admin-shared-mount

Purpose:
- validate the composition rule `CAP_SYS_ADMIN + non-private mount propagation`
- use only a controlled host bind subtree prepared for shared propagation

Should hit:
- `Thread has CAP_SYS_ADMIN in its effective capability set`
- `Mount point with non-private status in mount tree`
- composition finding: `CAP_SYS_ADMIN combined with non-private mount propagation`

Should not hit:
- `Thread shares the host PID namespace`
- `Thread runs without seccomp filtering`
- `Host filesystem view /host is writable`

Suggested validation:

```bash
make prepare-shared
make up SCENARIO=cap-sys-admin-shared-mount
../bin/runtia --container-id crl-cap-sys-admin-shared-mount
./scripts/prove-cap-sys-admin-shared-mount.sh
make down SCENARIO=cap-sys-admin-shared-mount
make cleanup-shared
```

Case-study note:
- the probe mounts `tmpfs` only under a disposable subtree
- successful propagation onto the host-prepared shared bind mount shows that the container can make mount changes escape its own view
- this supports a `Fatal` composition rating because the mount capability and the weakened propagation boundary combine into a cross-boundary mount effect
