#!/bin/bash

# MLOps Project Setup Script
# Este script configura automáticamente el proyecto MLOps

set -e  # Exit on any error

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 MLOps Project Setup${NC}"
echo -e "${GREEN}======================${NC}"
echo ""

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado. Por favor instala Docker Desktop.${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está disponible. Por favor actualiza Docker.${NC}"
    exit 1
fi

echo -e "${YELLOW}✅ Docker y Docker Compose encontrados${NC}"

# Crear directorios necesarios
echo -e "${YELLOW}📁 Creando directorios necesarios...${NC}"
mkdir -p mlruns data dags scripts
chmod -R 777 mlruns

# Verificar que los archivos necesarios existan
required_files=("docker-compose.yaml" "Dockerfile.airflow" "requirements.txt" "scripts/train_model.py" "dags/train_model_dag.py")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Archivo requerido no encontrado: $file${NC}"
        exit 1
    fi
done

echo -e "${YELLOW}✅ Archivos requeridos encontrados${NC}"

# Verificar que el archivo de datos exista
if [ ! -f "data/df.pkl" ]; then
    echo -e "${YELLOW}⚠️  Archivo de datos 'data/df.pkl' no encontrado${NC}"
    echo -e "${YELLOW}   Asegúrate de tener el archivo de datos en la carpeta 'data/'${NC}"
    echo -e "${YELLOW}   El proyecto funcionará pero el entrenamiento fallará sin datos${NC}"
fi

# Construir imágenes Docker
echo -e "${YELLOW}🔨 Construyendo imágenes Docker...${NC}"
docker compose build

# Iniciar PostgreSQL
echo -e "${YELLOW}🗄️  Iniciando PostgreSQL...${NC}"
docker compose up -d postgres

# Esperar a que PostgreSQL esté listo
echo -e "${YELLOW}⏳ Esperando que PostgreSQL esté listo...${NC}"
timeout 60 bash -c 'until docker compose exec postgres pg_isready -U airflow; do sleep 2; done' || {
    echo -e "${RED}❌ PostgreSQL no se inició correctamente${NC}"
    echo -e "${YELLOW}📋 Logs de PostgreSQL:${NC}"
    docker compose logs postgres
    exit 1
}

echo -e "${YELLOW}✅ PostgreSQL está listo${NC}"

# Inicializar base de datos de Airflow
echo -e "${YELLOW}🗄️  Inicializando base de datos de Airflow...${NC}"
docker compose run --rm airflow-webserver airflow db migrate

# Levantar todos los servicios
echo -e "${YELLOW}🚀 Levantando todos los servicios...${NC}"
docker compose up -d

# Esperar a que los servicios estén listos
echo -e "${YELLOW}⏳ Esperando que los servicios estén listos...${NC}"
sleep 15

# Verificar estado de los servicios
echo -e "${YELLOW}📊 Verificando estado de los servicios...${NC}"
docker compose ps

# Crear usuario administrador
echo -e "${YELLOW}👤 Creando usuario administrador...${NC}"
docker compose exec airflow-webserver airflow users create \
    --role Admin \
    --username admin \
    --password admin \
    --firstname Admin \
    --lastname User \
    --email admin@example.com || echo -e "${YELLOW}Usuario ya existe${NC}"

# Ejecutar entrenamiento inicial si hay datos
if [ -f "data/df.pkl" ]; then
    echo -e "${YELLOW}🤖 Ejecutando entrenamiento inicial...${NC}"
    docker compose exec airflow-webserver python /opt/airflow/scripts/train_model.py || {
        echo -e "${YELLOW}⚠️  El entrenamiento falló, pero los servicios están funcionando${NC}"
    }
else
    echo -e "${YELLOW}⚠️  Saltando entrenamiento inicial (no hay datos)${NC}"
fi

echo ""
echo -e "${GREEN}✅ ¡Configuración completada!${NC}"
echo ""
echo -e "${GREEN}🔗 URLs disponibles:${NC}"
echo -e "  📊 Airflow UI: http://localhost:8080"
echo -e "  🧪 MLflow UI: http://localhost:5001"
echo -e "  🗄️  PostgreSQL: localhost:5432"
echo ""
echo -e "${GREEN}👤 Credenciales:${NC}"
echo -e "  Usuario: admin"
echo -e "  Contraseña: admin"
echo ""
echo -e "${GREEN}📋 Comandos útiles:${NC}"
echo -e "  make status    - Ver estado de servicios"
echo -e "  make logs      - Ver logs"
echo -e "  make train     - Ejecutar entrenamiento"
echo -e "  make ui        - Abrir interfaces web"
echo -e "  make down      - Parar servicios"
echo -e "  make restart   - Reiniciar servicios"
echo ""
echo -e "${GREEN}🎉 ¡El proyecto MLOps está listo para usar!${NC}"
