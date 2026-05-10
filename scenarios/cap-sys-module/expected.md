# cap-sys-module

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_SYS_MODULE`
- show the shortest safe proof: the process can reach the module-management path without mutating host module state

Should hit:
- `Thread has CAP_SYS_MODULE in its effective capability set`

Suggested validation:

```bash
make prepare-cap-sys-module
make up SCENARIO=cap-sys-module
../bin/runtia --container-id crl-cap-sys-module
./scripts/prove-cap-sys-module.sh
make down SCENARIO=cap-sys-module
make cleanup-cap-sys-module
```

Case-study note:
- the helper calls `delete_module` on a deliberately non-existent module name
- success means the call passed the capability gate and reached module-management logic, but no module state changed
