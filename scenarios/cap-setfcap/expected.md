# cap-setfcap

Purpose:
- validate the single-rule `HighRisk` capability finding for `CAP_SETFCAP`
- show the shortest painful effect: the process can stamp a file capability onto an executable

Should hit:
- `Thread has CAP_SETFCAP in its effective capability set`

Suggested validation:

```bash
make up SCENARIO=cap-setfcap
../bin/runtia --container-id crl-cap-setfcap
./scripts/prove-cap-setfcap.sh
make down SCENARIO=cap-setfcap
```

Case-study note:
- the pain point is not immediate code execution by itself
- it is the ability to plant future privilege-bearing executables in reachable writable paths
