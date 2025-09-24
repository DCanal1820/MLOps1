## MLOps - Entrenamiento y Tracking con Airflow + MLflow

Este proyecto empaqueta el entrenamiento del modelo de `Aprendizaje_de_maquina_ultima_version` con:

- Airflow (Webserver + Scheduler + Postgres)
- MLflow UI para tracking (montando `./mlruns`)
- Scripts y DAG mínimos para ejecutar el entrenamiento

### Estructura

```
mlops-tp-final/
  dags/
    train_model_dag.py          # DAG que ejecuta el entrenamiento
  scripts/
    train_model.py              # Entrenamiento (scikit-learn + MLflow)
  data/
    df.pkl                      # Dataset usado por el script
  mlruns/                       # Store local de MLflow (experimentos y artefactos)
  Dockerfile.airflow            # Imagen de Airflow con dependencias de ML
  docker-compose.yaml           # Servicios: postgres, airflow, mlflow-ui
  Makefile                      # Comandos útiles
  README.md                     # Este documento
```

### Requisitos

- Docker Desktop y Docker Compose
- macOS / Linux / Windows WSL2

### Puertos

- Airflow: `http://localhost:8080`
- MLflow UI: `http://localhost:5001`

### Puesta en marcha (rápida)

1) Construir y levantar
```
make build
make up
```

2) Inicializar Airflow y crear usuario admin
```
make init
make user
```

3) Abrir las UIs
```
make ui
```

4) Ejecutar entrenamiento

- Opción A (desde Airflow): entrar a `http://localhost:8080`, loguearte con `admin/admin`, activar y ejecutar el DAG `entrenamiento_modelo_ml`.
- Opción B (directo):
```
make train
```

5) Ver resultados en MLflow

- Abrir `http://localhost:5001` y entrar al experimento `Default`. Verás el run con métricas y el modelo en `artifacts/`.

### Notas técnicas

- El script `scripts/train_model.py` lee los datos desde `/opt/airflow/data/df.pkl` (mapeado desde `./data/`).
- El tracking de MLflow se realiza contra `http://host.docker.internal:5001` desde los contenedores, por lo que la UI local (`http://localhost:5001`) mostrará los runs.
- Los artefactos y runs persisten en `./mlruns/` (montado en MLflow UI y Airflow).

### Comandos útiles

```
make ps         # Ver estado de contenedores
make logs       # Logs de los servicios
make restart    # Reinicia todo el stack
make down       # Apaga los servicios
```

### Problemas comunes

- "Airflow pide inicializar DB": ejecutar `make init`.
- "No puedo loguearme": ejecutar `make user` para recrear `admin/admin`.
- "MLflow UI vacía": recargar con Cmd+Shift+R; validar que el contenedor `mlflow-ui` esté `Up` (`make ps`).
- "Entrenamiento falla leyendo df.pkl": asegurate de que `mlops-tp-final/data/df.pkl` exista.

### Entrega

Para entregar al cliente:

1) Incluir esta carpeta `mlops-tp-final/` en el repo (excluyendo `data/`, `mlruns/` y `models/` por `.gitignore`).
2) Instruir a ejecutar los pasos de "Puesta en marcha" (build, up, init, user, ui, train).
3) Validar que las UIs respondan y que el run aparezca en MLflow.


