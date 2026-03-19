# Design Notes

## Why the repository uses ordinary images plus risky runtime configuration

Runtime detectors should be validated against runtime state, not against image drama.
An ordinary base image keeps the variable under test narrow: namespace attachment, capability sets, seccomp mode, bind mount flags, and propagation markers.
That makes the lab easier to reason about, easier to reproduce, and safer to run in an isolated VM because the image itself does not contain exploit code, persistence logic, or external control behavior.

## Why these samples are a better fit for runtime detection

A runtime detector usually consumes host-observable signals such as:
- namespace inode equality
- `/proc/<pid>/status` fields like `CapEff`, `CapPrm`, and `Seccomp`
- `/proc/<pid>/mountinfo` optional fields and mount flags

The detector is therefore strongest when each sample changes one runtime dimension while everything else stays ordinary.
That is why each scenario uses the same toolbox image and only introduces a single high-risk configuration whenever possible.

## Shared mount design

The `shared-mount` scenario is intentionally split into host preparation plus Compose startup.

1. The host script creates a bind mount at `/tmp/container-risk-labs/shared-mount/shared-bind`.
2. The host script marks that bind mount as shared with `mount --make-shared`.
3. The Compose file bind-mounts that host path into the container with `bind.propagation: shared`.

This produces a mount inside the container whose `mountinfo` contains an optional field such as `shared:402`.
The container does not need to run as privileged and does not need to create a mount event itself.
That makes the sample safer while still giving the detector a real shared-propagation marker to parse.

## Read-only parent with read-write child design

The `ro-parent-rw-child` scenario prepares a normal host directory tree:
- parent: `/tmp/container-risk-labs/ro-parent-rw-child/parent`
- child: `/tmp/container-risk-labs/ro-parent-rw-child/parent/writable-child`

Compose then applies two bind mounts:
1. the parent path is mounted at `/lab/overlay-parent` as read-only
2. the child path is mounted again at `/lab/overlay-parent/writable-child` as read-write

The result is a nested mount tree in which the parent subtree looks read-only while the child subtree is writable.
A detector should compare mount ancestry rather than inspecting only the nearest mountpoint, otherwise this override pattern can be missed.

## Mapping between scenarios and detector signals

- `baseline`: negative control for namespace, capability, seccomp, and mount propagation rules
- `host-pidns`: compare container PID namespace inode with the host PID namespace inode
- `cap-sys-admin`: decode `CapEff` or `CapPrm` and verify the `CAP_SYS_ADMIN` bit is present
- `seccomp-unconfined`: inspect seccomp mode and distinguish Docker default filtered seccomp from explicit unconfined mode
- `shared-mount`: parse `mountinfo` optional fields and detect `shared:X`
- `ro-parent-rw-child`: walk the mount tree and detect a read-only ancestor with a read-write child mount

