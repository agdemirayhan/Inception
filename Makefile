# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ayhan <ayhan@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/01/01 14:18:11 by ayhan           #+#    #+#              #
#    Updated: 2023/01/07 01:59:32 by ayhan          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #



all : up

up : 
	@docker-compose -f ./srcs/docker-compose.yml up -d

down : 
	@docker-compose -f ./srcs/docker-compose.yml down

stop : 
	@docker-compose -f ./srcs/docker-compose.yml stop

start : 
	@docker-compose -f ./srcs/docker-compose.yml start

status : 
	@docker ps
