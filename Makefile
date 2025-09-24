SHELL := /bin/bash

.PHONY: build up down restart logs init user train ui ps

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart:
	$(MAKE) down || true
	$(MAKE) up

ps:
	docker compose ps

logs:
	docker compose logs -f --tail=200

init:
	docker compose run --rm airflow-webserver airflow db migrate

user:
	docker compose exec airflow-webserver airflow users create --role Admin --username admin --password admin --firstname Admin --lastname User --email admin@example.com || true

train:
	docker compose exec airflow-webserver python /opt/airflow/scripts/train_model.py

ui:
	open http://localhost:8080 || xdg-open http://localhost:8080 || true
	open http://localhost:5001 || xdg-open http://localhost:5001 || true

