COMPOSE = docker compose \
		  --env-file .env \
		  -f compose/compose.yml

SERVICE ?=

.DEFAULT_GOAL = up
.PHONY: up stop restart down logs ps shell

check_service:
	@if [ -z "$(SERVICE)" ]; then \
		echo "SERVICE is not set. Usage make [cmd] SERVICE=foo"; \
		exit 1; \
	fi

up:
	$(COMPOSE) up -d

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart $(SERVICE)

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f $(SERVICE)

ps:
	$(COMPOSE) ps

shell: check_service
	$(COMPOSE) exec $(SERVICE) sh

