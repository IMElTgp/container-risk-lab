# cap-net-raw

Purpose:
- validate the single-rule `HighRisk` capability finding for `CAP_NET_RAW`
- show the shortest painful effect: the process can open a raw packet socket directly

Should hit:
- `Thread has CAP_NET_RAW in its effective capability set`

Suggested validation:

```bash
make prepare-cap-net-raw
make up SCENARIO=cap-net-raw
../bin/runtia --container-id crl-cap-net-raw
./scripts/prove-cap-net-raw.sh
make down SCENARIO=cap-net-raw
make cleanup-cap-net-raw
```

Case-study note:
- raw sockets are the direct primitive behind packet capture and packet forgery paths
- the probe keeps this minimal by only opening the socket and closing it
