NAME			= inception
SRC_DIR			= srcs
COMPOSE_FILE	= $(SRC_DIR)/docker-compose.yml
ENV_FILE		= $(SRC_DIR)/.env

# Use 'docker compose' if available, otherwise fallback to 'docker-compose'
DOCKER_COMPOSE	= $(shell command -v docker compose >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

.PHONY: all up down build re ps logs

all: up

# Build containers
build:
	@echo " Building $(NAME)..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build

# Start containers
up: build
	@echo " Starting $(NAME) containers..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d

# Stop containers
down:
	@echo " Stopping $(NAME) containers..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# Rebuild from scratch
re: down all

# Show running containers
ps:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

# Follow logs
logs:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f
