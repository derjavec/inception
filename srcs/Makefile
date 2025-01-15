name = inception

COMPOSE_FILE = docker-compose.yml

DATA_DIR = ~/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb

all:
	@printf "Launching configuration $(name)...\n"
	@mkdir -p $(WORDPRESS_DIR) $(MARIADB_DIR)
	@docker compose -f ./srcs/$(COMPOSE_FILE) --env-file srcs/.env up -d

build:
	@printf "Building configuration $(name)...\n"
	@mkdir -p $(WORDPRESS_DIR) $(MARIADB_DIR)
	@docker compose -f ./srcs/$(COMPOSE_FILE) --env-file srcs/.env build

down:
	@printf "Stopping configuration $(name)...\n"
	@docker compose -f ./srcs/$(COMPOSE_FILE) --env-file srcs/.env down

re:
	@printf "Rebuilding configuration $(name)...\n"
	@docker compose -f ./srcs/$(COMPOSE_FILE) --env-file srcs/.env down
	@docker compose -f ./srcs/$(COMPOSE_FILE) --env-file srcs/.env up -d --build

clean: down
	@printf "Cleaning configuration $(name)...\n"
	@sudo rm -rf $(WORDPRESS_DIR) $(MARIADB_DIR)
	@docker system prune -a --force

fclean: clean
	@printf "Performing a full Docker cleanup...\n"
	@docker compose -f ./srcs/$(COMPOSE_FILE) down -v
	@docker system prune --all --force --volumes
	@sudo rm -rf $(WORDPRESS_DIR) $(MARIADB_DIR)

.PHONY: all build down re clean fclean
