# cap-sys-resource

Purpose:
- validate the single-rule `HighRisk` capability finding for `CAP_SYS_RESOURCE`
- show the shortest painful effect: the process can raise its own hard resource limit after first constraining it

Should hit:
- `Thread has CAP_SYS_RESOURCE in its effective capability set`

Suggested validation:

```bash
make up SCENARIO=cap-sys-resource
../bin/runtia --container-id crl-cap-sys-resource
./scripts/prove-cap-sys-resource.sh
make down SCENARIO=cap-sys-resource
```

Case-study note:
- the pain point is not “one more file descriptor”
- it is that the process can undo its own hard resource boundary instead of staying confined by it
