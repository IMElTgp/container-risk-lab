# cap-sys-rawio

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_SYS_RAWIO`
- show the shortest painful effect without touching hardware: the process can grant itself direct I/O-port access

Should hit:
- `Thread has CAP_SYS_RAWIO in its effective capability set`

Suggested validation:

```bash
make prepare-cap-sys-rawio
make up SCENARIO=cap-sys-rawio
../bin/runtia --container-id crl-cap-sys-rawio
./scripts/prove-cap-sys-rawio.sh
make down SCENARIO=cap-sys-rawio
make cleanup-cap-sys-rawio
```

Case-study note:
- the helper only changes the calling thread's I/O-port permission bitmap
- it does not perform real port I/O against host hardware
