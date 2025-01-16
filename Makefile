name = inception

COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE_CMD = docker compose -f ./$(COMPOSE_FILE) --env-file srcs/.env

DATA_DIR = ~/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb

all:
	printf "Launching configuration $(name)...\n"
	mkdir -p $(WORDPRESS_DIR) $(MARIADB_DIR)
	$(COMPOSE_CMD) build
	$(COMPOSE_CMD) up -d

build:
	printf "Building configuration $(name)...\n"
	mkdir -p $(WORDPRESS_DIR) $(MARIADB_DIR)
	$(COMPOSE_CMD) build

down:
	printf "Stopping configuration $(name)...\n"
	$(COMPOSE_CMD) down

re:
	printf "Rebuilding configuration $(name)...\n"
	$(COMPOSE_CMD) down
	$(COMPOSE_CMD) up -d

clean: down
	printf "Cleaning configuration $(name)...\n"
	sudo rm -rf $(WORDPRESS_DIR) $(MARIADB_DIR)
	docker system prune -a --force

fclean: clean
	printf "Performing a full Docker cleanup...\n"
	$(COMPOSE_CMD) down -v
	docker system prune --all --force --volumes
	sudo rm -rf $(WORDPRESS_DIR) $(MARIADB_DIR)

.PHONY: all build down re clean fclean

