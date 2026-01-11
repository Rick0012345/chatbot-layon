SHELL := /bin/bash

IP := 72.62.10.128
USER := root

CHATBOT_REMOTE := ~/chatbot-n8n
CHATBOT_COMPOSE := docker-compose-chatbot.yml
CHATBOT_ENV := .env.chatbot
.PHONY: deploy-chatbot verify-chatbot prep-chatbot push-chatbot up-chatbot

# Deploy único do chatbot (usa Dockerfile + compose)
deploy-chatbot: verify-chatbot prep-chatbot push-chatbot up-chatbot

verify-chatbot:
	@set -euo pipefail; \
	[ -f $(CHATBOT_COMPOSE) ] || { echo "Faltando $(CHATBOT_COMPOSE)"; exit 1; }; \
	[ -f $(CHATBOT_ENV) ] || { echo "Faltando $(CHATBOT_ENV)"; exit 1; }

prep-chatbot:
	@ssh $(USER)@$(IP) "mkdir -p $(CHATBOT_REMOTE); if command -v ufw >/dev/null 2>&1; then ufw allow 5681/tcp; fi"

push-chatbot:
	@scp $(CHATBOT_COMPOSE) $(CHATBOT_ENV) Dockerfile docker-entrypoint.sh "chatbot postgres 6.0.json" "CRIAR TABELAS.json" "inatividade-trigger.json" $(USER)@$(IP):$(CHATBOT_REMOTE)/

up-chatbot:
	@ssh $(USER)@$(IP) "cd $(CHATBOT_REMOTE) \
	&& mv $(CHATBOT_ENV) .env \
	&& mv $(CHATBOT_COMPOSE) docker-compose.yml \
	&& (docker compose down --remove-orphans || true) \
	&& (docker rm -f chatbot-traefik chatbot-worker chatbot-redis chatbot-caddy caddy traefik 2>/dev/null || true) \
	&& docker compose build \
	&& docker compose up -d --force-recreate --remove-orphans"
