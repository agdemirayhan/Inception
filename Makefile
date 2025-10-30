NAME = inception
DOCKER = cd srcs && docker compose -f docker-compose.yml

all: up

up:
	mkdir -p /home/ayhan/data/db
	mkdir -p /home/ayhan/data/wp
# 	$(DOCKER) up --build
	$(DOCKER) up -d --build

down:
	$(DOCKER) down

clean:
	$(DOCKER) down -v

fclean: clean
	@echo "🧹 Removing host data volumes..."
	sudo rm -rf /home/ayhan/data/db
	sudo rm -rf /home/ayhan/data/wp
	@echo "🧼 Pruning Docker system..."
	docker system prune -af --volumes

re: fclean up

.PHONY: all up down clean fclean re
