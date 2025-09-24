SHELL := /bin/bash

# Variables
PROJECT_NAME := mlops-tp-final
AIRFLOW_UI_PORT := 8080
MLFLOW_UI_PORT := 5001
POSTGRES_PORT := 5432

# Colores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help build up down restart logs init user train ui ps status clean setup first-time

# Comando por defecto
.DEFAULT_GOAL := help

help: ## Mostrar esta ayuda
	@echo "$(GREEN)MLOps Project - Comandos disponibles:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Para primera vez:$(NC) make setup"
	@echo "$(GREEN)Para usar normalmente:$(NC) make up"

setup: ## Configuración inicial completa (primera vez)
	@echo "$(GREEN)🚀 Configuración inicial del proyecto MLOps...$(NC)"
	@echo "$(YELLOW)1. Creando directorios necesarios...$(NC)"
	@mkdir -p mlruns data dags scripts
	@chmod -R 777 mlruns
	@echo "$(YELLOW)2. Construyendo imágenes Docker...$(NC)"
	@$(MAKE) build
	@echo "$(YELLOW)3. Iniciando servicios base...$(NC)"
	@docker compose up -d postgres
	@echo "$(YELLOW)4. Esperando que PostgreSQL esté listo...$(NC)"
	@timeout 30 bash -c 'until docker compose exec postgres pg_isready -U airflow; do sleep 2; done' || true
	@echo "$(YELLOW)5. Inicializando base de datos de Airflow...$(NC)"
	@docker compose run --rm airflow-webserver airflow db migrate
	@echo "$(YELLOW)6. Levantando todos los servicios...$(NC)"
	@docker compose up -d
	@echo "$(YELLOW)7. Esperando que los servicios estén listos...$(NC)"
	@sleep 10
	@echo "$(YELLOW)8. Creando usuario administrador...$(NC)"
	@$(MAKE) user
	@echo "$(YELLOW)9. Ejecutando entrenamiento inicial...$(NC)"
	@$(MAKE) train
	@echo ""
	@echo "$(GREEN)✅ ¡Configuración completada!$(NC)"
	@echo "$(GREEN)📊 Airflow UI: http://localhost:$(AIRFLOW_UI_PORT)$(NC)"
	@echo "$(GREEN)🧪 MLflow UI: http://localhost:$(MLFLOW_UI_PORT)$(NC)"
	@echo "$(GREEN)👤 Usuario: admin / Contraseña: admin$(NC)"

first-time: setup ## Alias para setup (primera vez)

up: ## Levantar servicios (uso normal)
	@echo "$(GREEN)🚀 Levantando servicios MLOps...$(NC)"
	@docker compose up -d
	@echo "$(YELLOW)Esperando que los servicios estén listos...$(NC)"
	@sleep 5
	@$(MAKE) status

down: ## Parar todos los servicios
	@echo "$(YELLOW)🛑 Parando servicios...$(NC)"
	@docker compose down

restart: ## Reiniciar todos los servicios
	@echo "$(YELLOW)🔄 Reiniciando servicios...$(NC)"
	@$(MAKE) down
	@$(MAKE) up

build: ## Construir imágenes Docker
	@echo "$(YELLOW)🔨 Construyendo imágenes Docker...$(NC)"
	@docker compose build

ps: ## Mostrar estado de contenedores
	@docker compose ps

status: ## Mostrar estado detallado
	@echo "$(GREEN)📊 Estado de los servicios:$(NC)"
	@$(MAKE) ps
	@echo ""
	@echo "$(GREEN)🔗 URLs disponibles:$(NC)"
	@echo "  Airflow UI: http://localhost:$(AIRFLOW_UI_PORT)"
	@echo "  MLflow UI: http://localhost:$(MLFLOW_UI_PORT)"
	@echo "  PostgreSQL: localhost:$(POSTGRES_PORT)"

logs: ## Ver logs de todos los servicios
	@docker compose logs -f --tail=100

logs-airflow: ## Ver logs de Airflow
	@docker compose logs -f --tail=50 airflow-webserver airflow-scheduler

logs-mlflow: ## Ver logs de MLflow
	@docker compose logs -f --tail=50 mlflow-ui

init: ## Inicializar base de datos de Airflow
	@echo "$(YELLOW)🗄️ Inicializando base de datos...$(NC)"
	@docker compose run --rm airflow-webserver airflow db migrate

user: ## Crear usuario administrador de Airflow
	@echo "$(YELLOW)👤 Creando usuario administrador...$(NC)"
	@docker compose exec airflow-webserver airflow users create \
		--role Admin \
		--username admin \
		--password admin \
		--firstname Admin \
		--lastname User \
		--email admin@example.com || echo "$(YELLOW)Usuario ya existe$(NC)"

train: ## Ejecutar entrenamiento del modelo
	@echo "$(YELLOW)🤖 Ejecutando entrenamiento...$(NC)"
	@docker compose exec airflow-webserver python /opt/airflow/scripts/train_model.py

ui: ## Abrir interfaces web
	@echo "$(GREEN)🌐 Abriendo interfaces web...$(NC)"
	@open http://localhost:$(AIRFLOW_UI_PORT) 2>/dev/null || xdg-open http://localhost:$(AIRFLOW_UI_PORT) 2>/dev/null || true
	@open http://localhost:$(MLFLOW_UI_PORT) 2>/dev/null || xdg-open http://localhost:$(MLFLOW_UI_PORT) 2>/dev/null || true

clean: ## Limpiar todo (contenedores, volúmenes, datos)
	@echo "$(RED)🧹 Limpiando proyecto...$(NC)"
	@docker compose down -v --remove-orphans
	@rm -rf mlruns/ __pycache__/ .pytest_cache/
	@find . -name "*.pyc" -delete
	@echo "$(GREEN)✅ Limpieza completada$(NC)"

reset: clean setup ## Reset completo (limpiar + configurar desde cero)

# Comandos de desarrollo
dev-logs: ## Ver logs en tiempo real
	@docker compose logs -f

shell-airflow: ## Acceder al shell de Airflow
	@docker compose exec airflow-webserver bash

shell-mlflow: ## Acceder al shell de MLflow
	@docker compose exec mlflow-ui sh

