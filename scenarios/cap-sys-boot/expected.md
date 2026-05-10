# cap-sys-boot

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_SYS_BOOT`
- show the shortest safe proof: in a private PID namespace, the process can pass the reboot capability gate without issuing a real reboot command

Should hit:
- `Thread has CAP_SYS_BOOT in its effective capability set`

Suggested validation:

```bash
make prepare-cap-sys-boot
make up SCENARIO=cap-sys-boot
../bin/runtia --container-id crl-cap-sys-boot
./scripts/prove-cap-sys-boot.sh
make down SCENARIO=cap-sys-boot
make cleanup-cap-sys-boot
```

Case-study note:
- the helper uses valid reboot magic values but an invalid command value
- a successful proof is `EINVAL` instead of `EPERM`
- no real reboot command is issued
