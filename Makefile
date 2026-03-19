SCENARIO ?= baseline
IMAGE ?= container-risk-labs-toolbox:local
COMPOSE ?= $(shell \
	if docker compose version >/dev/null 2>&1; then \
		printf '%s' 'docker compose'; \
	elif docker-compose version >/dev/null 2>&1; then \
		printf '%s' 'docker-compose'; \
	else \
		printf '%s' 'docker compose'; \
	fi)

.PHONY: build up down ps prepare-shared cleanup-shared prepare-ro-rw cleanup-ro-rw

build:
	docker build -t $(IMAGE) ./base

up:
	$(COMPOSE) -f scenarios/$(SCENARIO)/docker-compose.yml up -d

down:
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
