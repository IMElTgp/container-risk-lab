# cap-bpf

Purpose:
- validate the single-rule `Fatal` capability finding for `CAP_BPF`
- show the shortest painful effect without host hooks: the process can load and execute a minimal eBPF program directly

Should hit:
- `Thread has CAP_BPF in its effective capability set`

Suggested validation:

```bash
make prepare-cap-bpf
make up SCENARIO=cap-bpf
../bin/runtia --container-id crl-cap-bpf
./scripts/prove-cap-bpf.sh
make down SCENARIO=cap-bpf
make cleanup-cap-bpf
```

Case-study note:
- the helper does not attach to kprobes, tracepoints, tc, XDP, or cgroups
- it does not pin objects into host bpffs
- it only proves that the container can hand eBPF bytecode to the kernel, pass verification, and execute it with `BPF_PROG_TEST_RUN`
