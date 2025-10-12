COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env

all: up

up:
	@mkdir -p /home/$$(grep LOGIN srcs/.env | cut -d= -f2)/data/db
	@mkdir -p /home/$$(grep LOGIN srcs/.env | cut -d= -f2)/data/wp
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build --no-cache

logs:
	$(COMPOSE) logs -f --tail=100

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af

re: fclean all
