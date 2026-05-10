# cap-perfmon

Purpose:
- validate the single-rule `HighRisk` capability finding for `CAP_PERFMON`
- show the shortest painful effect: the process can open a perf event directly

Should hit:
- `Thread has CAP_PERFMON in its effective capability set`

Suggested validation:

```bash
make prepare-cap-perfmon
make up SCENARIO=cap-perfmon
../bin/runtia --container-id crl-cap-perfmon
./scripts/prove-cap-perfmon.sh
make down SCENARIO=cap-perfmon
make cleanup-cap-perfmon
```

Case-study note:
- the probe stays container-local
- the pain point is direct access to perf monitoring primitives that can expose cross-process or cross-container execution information
