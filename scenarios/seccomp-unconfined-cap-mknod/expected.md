# seccomp-unconfined-cap-mknod

Purpose:
- validate the composition rule `seccomp unconfined + high-risk capability`
- use `CAP_MKNOD` as a concrete high-risk capability with an easy local probe

Should hit:
- `Thread runs without seccomp filtering`
- `Thread has CAP_MKNOD in its effective capability set`
- composition finding: `Unconfined seccomp combined with high-risk capability`

Should not hit:
- `Thread shares the host PID namespace`
- `Host filesystem view /host is writable`
- `Mount point with non-private status in mount tree`

Suggested validation:

```bash
make up SCENARIO=seccomp-unconfined-cap-mknod
../bin/runtia --container-id crl-seccomp-unconfined-cap-mknod
docker exec crl-seccomp-unconfined-cap-mknod sh -lc 'rm -f /tmp/test-null && mknod /tmp/test-null c 1 3 && ls -l /tmp/test-null'
make down SCENARIO=seccomp-unconfined-cap-mknod
```

Case-study note:
- this scenario keeps the validation local to the container and avoids touching host mounts or namespaces
- `mknod` success provides a concrete post-detection action showing that the container still holds a capability with real kernel-facing effect while seccomp is completely disabled

