SHELL := /bin/bash
DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null || echo "docker compose")
COMPOSE_FILE_PROD := docker-compose.yml
COMPOSE_FILE_DEV := docker-compose-dev.yml
COMPOSE_FILE := $(if $(filter prod,$(env)),$(COMPOSE_FILE_PROD),$(if $(filter dev,$(env)),$(COMPOSE_FILE_DEV) -f $(COMPOSE_FILE_PROD)))

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check_env:
ifndef env
	$(error Please specify an environment (prod or dev) (eg: make build env=prod))
endif
ifeq (,$(filter $(env),prod dev))
	$(error Invalid environment specified. Please use 'prod' or 'dev'.)
endif

check_adapter:
ifndef adapter
	$(error Please specify an adapter (postgres or mysql) (eg: make setup env=prod adapter=postgres))
endif
ifeq (,$(filter $(adapter),postgres mysql))
	$(error Invalid adapter specified. Please use 'postgres' or 'mysql'.)
endif

check_docker_compose:
ifeq ($(strip $(DOCKER_COMPOSE)),)
	$(error 'docker-compose' or 'docker compose' command not found. Please make sure Docker Compose is installed.)
endif

define docker_action
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --profile $(env) $(1)
endef

setup: check_env check_adapter check_docker_compose ## Setup DMPOPIDoR configuration (env: prod or dev, adapter: postgres or mysql)
	$(call docker_action,run --rm dmpopidor sh -c 'ruby bin/docker $(adapter)')
	$(call docker_action,run --rm dmpopidor sh -c 'ruby bin/docker db:setup')

build: check_env check_docker_compose ## Build docker image (env: prod or dev)
	$(call docker_action,build dmpopidor)

run: check_env check_docker_compose ## Run services (env: prod or dev)
	$(call docker_action,up -d)

stop: check_env check_docker_compose ## Stop services (env: prod or dev)
	$(call docker_action,stop)

.PHONY: help check_env check_adapter check_docker_compose setup build run stop