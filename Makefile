COMPOSE = docker compose \
		  --env-file .env \
		  -f compose/compose.yml

SERVICE ?=

.PHONY: up stop restart down logs ps shell

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

shell:
	$(COMPOSE) exec $(SERVICE) sh

