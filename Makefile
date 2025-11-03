NAME			= inception
SRC_DIR			= srcs
COMPOSE_FILE	= $(SRC_DIR)/docker-compose.yml
ENV_FILE		= $(SRC_DIR)/.env
DATA_DIR		= /home/$(USER)/data
MARIADB_DIR		= $(DATA_DIR)/mariadb
WORDPRESS_DIR	= $(DATA_DIR)/wordpress

# Use 'docker compose' if available, otherwise fallback to 'docker-compose'
DOCKER_COMPOSE	= $(shell command -v docker compose >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

.PHONY: all up down build clean fclean re ps logs

all: up

# Build and run everything
up: build
	@echo " Starting $(NAME) containers..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d

# Build containers only
build:
	@echo " Building $(NAME)..."
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build

# Stop and remove containers
down:
	@echo " Stopping $(NAME) containers..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# Clean images and stopped containers
clean: down
	@echo " Cleaning unused Docker resources..."
	@docker system prune -af --volumes

# Full clean: removes data volumes and network
fclean: clean
	@echo " Removing all persistent data..."
	@sudo rm -rf $(WORDPRESS_DIR)/* $(MARIADB_DIR)/*
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker network rm $$(docker network ls -q | grep inception) 2>/dev/null || true

# Rebuild from scratch
re: fclean all

# Show running containers
ps:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

# Show logs
logs:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f
