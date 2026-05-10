# cap-dac-override-single

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_DAC_OVERRIDE`
- show the shortest painful effect: the process can modify a controlled file whose DAC mode is `000`

Should hit:
- `Thread has CAP_DAC_OVERRIDE in its effective capability set`

Suggested validation:

```bash
make prepare-dac
make up SCENARIO=cap-dac-override-single
../bin/runtia --container-id crl-cap-dac-override-single
./scripts/prove-cap-dac-override-single.sh
make down SCENARIO=cap-dac-override-single
make cleanup-dac
```

Case-study note:
- the target is a controlled host bind mount under `/tmp/container-risk-labs`
- the bind mount is attached at `/lab`, specifically to avoid introducing a separate writable-host-mount finding
- the container root filesystem is read-only, so the proof stays focused on the capability itself
- the file starts at mode `000`
- the proof shows direct DAC-bypass write, but keeps the blast radius inside a disposable host asset
