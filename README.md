# Inception

A system administration project from 42 Network that involves setting up a containerized infrastructure using Docker and Docker Compose.

## Overview

Inception requires building a small infrastructure composed of different services running in dedicated Docker containers. The entire setup is orchestrated with Docker Compose and runs on a virtual machine.

## Services

- **NGINX** — Web server with TLS (SSL/TLS only, port 443)
- - **WordPress** — PHP-based CMS connected to MariaDB
  - - **MariaDB** — Database backend for WordPress
   
    - ## Architecture
   
    - ```
                        ┌─────────────────────────────────┐
                        │        Docker Network            │
        Port 443 ──────▶│  NGINX ──▶ WordPress ──▶ MariaDB│
                        └─────────────────────────────────┘
      ```

      - Each service runs in its own container
      - - Containers communicate over a custom Docker network
        - - Data is persisted using Docker volumes
          - - Environment variables and secrets are managed via `.env` and `secrets/`
           
            - ## Project Structure
           
            - ```
              .
              ├── Makefile
              ├── secrets/          # Sensitive credentials (not committed)
              └── srcs/
                  ├── docker-compose.yml
                  └── requirements/
                      ├── nginx/
                      ├── wordpress/
                      └── mariadb/
              ```

              ## Usage

              ```bash
              # Build and start all services
              make

              # Stop and remove containers
              make down

              # Clean all volumes and images
              make clean
              ```

              ## Requirements

              - Docker
              - - Docker Compose
                - - Make
                 
                  - ## Notes
                 
                  - - All Docker images are built from scratch using `Debian:bullseye` or `Alpine` — no pre-built images (e.g., DockerHub nginx/wordpress images) are used
                    - - NGINX is the only entry point; exposed on port 443 with TLS
                      - - WordPress and MariaDB are not directly accessible from outside the Docker network
