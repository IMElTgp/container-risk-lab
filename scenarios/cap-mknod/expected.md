# cap-mknod

Purpose:
- validate the single-rule `HighRisk` capability finding for `CAP_MKNOD`
- show the shortest painful effect: the process can create a device node directly

Should hit:
- `Thread has CAP_MKNOD in its effective capability set`

Suggested validation:

```bash
make up SCENARIO=cap-mknod
../bin/runtia --container-id crl-cap-mknod
./scripts/prove-cap-mknod.sh
make down SCENARIO=cap-mknod
```

Case-study note:
- device-node creation is the direct primitive
- the probe uses `/tmp/test-null` as a controlled example
