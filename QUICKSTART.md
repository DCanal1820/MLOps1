# 🚀 Quick Start Guide

## Para Usuarios Nuevos

### 1. Clonar y Configurar
```bash
git clone <tu-repositorio>
cd MLOps1
make setup
```

### 2. Acceder a las Interfaces
- **Airflow**: http://localhost:8080 (admin/admin)
- **MLflow**: http://localhost:5001

### 3. Ejecutar Entrenamiento
```bash
make train
```

## Para Uso Diario

### Levantar Servicios
```bash
make up
```

### Parar Servicios
```bash
make down
```

### Ver Estado
```bash
make status
```

## Comandos de Emergencia

### Reset Completo
```bash
make reset
```

### Ver Logs
```bash
make logs
```

### Limpiar Todo
```bash
make clean
```

## ¿Problemas?

1. **Servicios no arrancan**: `make reset`
2. **Error de base de datos**: `make init`
3. **Sin datos**: Coloca `df.pkl` en `data/`
4. **Puerto ocupado**: Cambia puertos en `docker-compose.yaml`

## URLs Importantes

- Airflow UI: http://localhost:8080
- MLflow UI: http://localhost:5001
- PostgreSQL: localhost:5432

**¡Eso es todo! 🎉**
