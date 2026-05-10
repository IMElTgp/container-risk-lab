# cap-dac-override-writable-host-mount

Purpose:
- validate the composition rule `CAP_DAC_OVERRIDE + writable host/sensitive mount`
- use only a controlled host bind mount under `/tmp/container-risk-labs`

Should hit:
- `Thread has CAP_DAC_OVERRIDE in its effective capability set`
- `Host filesystem view /host is writable`
- composition finding: `CAP_DAC_OVERRIDE combined with writable host or sensitive mount`

Should not hit:
- `Thread shares the host PID namespace`
- `Thread runs without seccomp filtering`
- `Mount point with non-private status in mount tree`

Suggested validation:

```bash
make prepare-dac
make up SCENARIO=cap-dac-override-writable-host-mount
../bin/runtia --container-id crl-cap-dac-override-writable-host-mount
./scripts/prove-cap-dac-override-host-mount.sh
make down SCENARIO=cap-dac-override-writable-host-mount
make cleanup-dac
```

Case-study note:
- `restricted.txt` starts at mode `000`
- the scenario is meaningful because the container only gets `CAP_DAC_OVERRIDE`, not the broad default capability set
- if the restricted-file write succeeds, it directly demonstrates DAC bypass against a controlled host bind mount
- if that write is blocked but the marker file is still writable, treat the result as "dangerous combination detected, exploit path further constrained by host hardening"
