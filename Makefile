NAME = inception
DOCKER = cd srcs && docker compose -f docker-compose.yml

all: up

up:
	mkdir -p /home/ayhan/data/db
	mkdir -p /home/ayhan/data/wp
	$(DOCKER) up -d --build

down:
	$(DOCKER) down

clean:
	$(DOCKER) down -v

fclean: clean
	docker system prune -af --volumes

re: fclean up

.PHONY: all up down clean fclean re
