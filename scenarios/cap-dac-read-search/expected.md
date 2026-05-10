# cap-dac-read-search

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_DAC_READ_SEARCH`
- show the shortest painful effect: the process can read a controlled file whose DAC mode is `000`

Should hit:
- `Thread has CAP_DAC_READ_SEARCH in its effective capability set`

Suggested validation:

```bash
make prepare-dac
make up SCENARIO=cap-dac-read-search
../bin/runtia --container-id crl-cap-dac-read-search
./scripts/prove-cap-dac-read-search.sh
make down SCENARIO=cap-dac-read-search
make cleanup-dac
```

Case-study note:
- the target is a controlled host bind mount under `/tmp/container-risk-labs`
- the bind mount is attached at `/lab`, specifically to avoid introducing a separate writable-host-mount finding
- the container root filesystem is read-only, so the proof stays focused on the capability itself
- the file starts at mode `000`
- the proof stays inside that controlled asset and does not touch host-global state
