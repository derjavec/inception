COMPOSE_FILE = docker-compose.yml
build:
	docker-compose -f $(COMPOSE_FILE) build
default: up

up:
	docker-compose -f $(COMPOSE_FILE) up -d
down:
	docker-compose -f $(COMPOSE_FILE) down
clean: down
	docker system prune -f
	docker volume prune -f
rebuild: down build up
.PHONY: build up down clean rebuild