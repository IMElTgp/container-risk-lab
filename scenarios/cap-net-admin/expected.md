# cap-net-admin

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_NET_ADMIN`
- use the shortest safe proof: change network interface state inside the container's private network namespace

Should hit:
- `Thread has CAP_NET_ADMIN in its effective capability set`

Suggested validation:

```bash
make up SCENARIO=cap-net-admin
../bin/runtia --container-id crl-cap-net-admin
./scripts/prove-cap-net-admin.sh
make down SCENARIO=cap-net-admin
```

Case-study note:
- the proof first checks that the container network namespace is different from the host
- it then adds a test address to `lo` inside the container
- the host loopback interface must stay unchanged
