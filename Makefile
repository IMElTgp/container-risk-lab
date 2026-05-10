SCENARIO ?= baseline
IMAGE ?= container-risk-labs-toolbox:local
COMPOSE ?= $(shell \
	if docker compose version >/dev/null 2>&1; then \
		printf '%s' 'docker compose'; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		printf '%s' 'docker-compose'; \
	fi)

.PHONY: build up down ps prepare-shared cleanup-shared prepare-ro-rw cleanup-ro-rw prepare-dac cleanup-dac prepare-cap-kill cleanup-cap-kill prepare-host-pidns cleanup-host-pidns prepare-cap-ptrace cleanup-cap-ptrace prepare-delayed-cap cleanup-delayed-cap prepare-cap-chroot cleanup-cap-chroot prepare-host-userns cleanup-host-userns prepare-host-writable cleanup-host-writable prepare-cap-net-raw cleanup-cap-net-raw prepare-cap-perfmon cleanup-cap-perfmon prepare-cap-setpcap cleanup-cap-setpcap prepare-cap-bpf cleanup-cap-bpf prepare-cap-sys-rawio cleanup-cap-sys-rawio prepare-cap-sys-module cleanup-cap-sys-module prepare-cap-sys-boot cleanup-cap-sys-boot

build:
	docker build -t $(IMAGE) ./base

up:
	@test -n "$(COMPOSE)" || { echo "No docker compose implementation found. Install docker compose plugin or docker-compose v1, or run the scenario with equivalent docker run commands."; exit 1; }
	$(COMPOSE) -f scenarios/$(SCENARIO)/docker-compose.yml up -d

down:
	@test -n "$(COMPOSE)" || { echo "No docker compose implementation found. Install docker compose plugin or docker-compose v1, or run the scenario with equivalent docker run commands."; exit 1; }
	$(COMPOSE) -f scenarios/$(SCENARIO)/docker-compose.yml down --remove-orphans

ps:
	docker ps \
		--filter label=container-risk-labs.repo=container-risk-labs \
		--format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'

prepare-shared:
	./scripts/prepare-shared-mount-host.sh

cleanup-shared:
	./scripts/cleanup-shared-mount-host.sh

prepare-ro-rw:
	./scripts/prepare-ro-parent-rw-child.sh

cleanup-ro-rw:
	./scripts/cleanup-ro-parent-rw-child.sh

prepare-dac:
	./scripts/prepare-dac-override-host-mount.sh

cleanup-dac:
	./scripts/cleanup-dac-override-host-mount.sh

prepare-cap-kill:
	./scripts/prepare-cap-kill-host-pidns.sh

cleanup-cap-kill:
	./scripts/cleanup-cap-kill-host-pidns.sh

prepare-host-pidns:
	./scripts/prepare-host-pidns-visibility.sh

cleanup-host-pidns:
	./scripts/cleanup-host-pidns-visibility.sh

prepare-cap-ptrace:
	./scripts/prepare-cap-sys-ptrace-host-pidns.sh

cleanup-cap-ptrace:
	./scripts/cleanup-cap-sys-ptrace-host-pidns.sh

prepare-delayed-cap:
	./scripts/prepare-no-new-privs-delayed-cap.sh

cleanup-delayed-cap:
	./scripts/cleanup-no-new-privs-delayed-cap.sh

prepare-cap-chroot:
	./scripts/prepare-cap-sys-chroot-mountns.sh

cleanup-cap-chroot:
	./scripts/cleanup-cap-sys-chroot-mountns.sh

prepare-host-userns:
	./scripts/prepare-host-userns.sh

cleanup-host-userns:
	./scripts/cleanup-host-userns.sh

prepare-host-writable:
	./scripts/prepare-writable-host-mount.sh

cleanup-host-writable:
	./scripts/cleanup-writable-host-mount.sh

prepare-cap-net-raw:
	./scripts/prepare-cap-net-raw.sh

cleanup-cap-net-raw:
	./scripts/cleanup-cap-net-raw.sh

prepare-cap-perfmon:
	./scripts/prepare-cap-perfmon.sh

cleanup-cap-perfmon:
	./scripts/cleanup-cap-perfmon.sh

prepare-cap-setpcap:
	./scripts/prepare-cap-setpcap.sh

cleanup-cap-setpcap:
	./scripts/cleanup-cap-setpcap.sh

prepare-cap-bpf:
	./scripts/prepare-cap-bpf.sh

cleanup-cap-bpf:
	./scripts/cleanup-cap-bpf.sh

prepare-cap-sys-rawio:
	./scripts/prepare-cap-sys-rawio.sh

cleanup-cap-sys-rawio:
	./scripts/cleanup-cap-sys-rawio.sh

prepare-cap-sys-module:
	./scripts/prepare-cap-sys-module.sh

cleanup-cap-sys-module:
	./scripts/cleanup-cap-sys-module.sh

prepare-cap-sys-boot:
	./scripts/prepare-cap-sys-boot.sh

cleanup-cap-sys-boot:
	./scripts/cleanup-cap-sys-boot.sh
