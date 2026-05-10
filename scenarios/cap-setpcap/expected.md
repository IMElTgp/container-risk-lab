# cap-setpcap

Purpose:
- validate the single-rule `HighRisk` capability finding for `CAP_SETPCAP`
- show the shortest painful effect: the process can rewrite its own capability state and immediately activate another retained capability

Should hit:
- `Thread has CAP_SETPCAP in its effective capability set`

Suggested validation:

```bash
make prepare-cap-setpcap
make up SCENARIO=cap-setpcap
../bin/runtia --container-id crl-cap-setpcap
./scripts/prove-cap-setpcap.sh
make down SCENARIO=cap-setpcap
make cleanup-cap-setpcap
```

Case-study note:
- the helper first clears `CAP_NET_RAW` from `CapEff`
- then uses `CAP_SETPCAP` to restore it into `CapEff`
- and finally proves the state change mattered by opening a raw socket
