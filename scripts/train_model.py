import mlflow
import os
import joblib
import numpy as np
import time
import pandas as pd
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor

# Configurar tracking apuntando al servidor MLflow UI en la host (Docker Desktop)
# Dentro del contenedor, la host se ve como "host.docker.internal"
mlflow.set_tracking_uri("http://host.docker.internal:5001")

# Cargar el DataFrame desde la carpeta montada en el contenedor
df = pd.read_pickle('/opt/airflow/data/df.pkl')

# Identificar las características (X) y la variable objetivo (y)
# Basado en tu notebook, la variable a predecir es 'descuento'
X = df.drop(columns=['descuento'])
y = df['descuento']

# Realizar la división de los datos directamente en el script
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=42)

# Parámetros del modelo (extraídos de tu notebook)
best_params = {
    'n_estimators': 30,
    'max_depth': 12,
    'min_samples_split': 2,
    'min_samples_leaf': 1
}

# Nombre del modelo
best_name = 'RandomForestRegressor'

# Iniciar la ejecución de MLflow
with mlflow.start_run():
    # Registrar los parámetros
    mlflow.log_params(best_params)
    
    # Instanciar el modelo
    best_est = RandomForestRegressor(**best_params)
    
    # Entrenar el modelo y medir el tiempo
    t0 = time.time()
    best_est.fit(Xtr, ytr)
    dt = time.time() - t0
    
    # Realizar predicciones y calcular métricas
    yhat = best_est.predict(Xte)
    mae = mean_absolute_error(yte, yhat)
    rmse = float(np.sqrt(mean_squared_error(yte, yhat)))
    r2 = r2_score(yte, yhat)
    
    # Registrar las métricas en MLflow
    mlflow.log_metric('mae', mae)
    mlflow.log_metric('rmse', rmse)
    mlflow.log_metric('r2', r2)
    mlflow.log_metric('fit_time', dt)
    
    # Guardar el modelo como archivo y loguearlo como artefacto (sin Model Registry)
    os.makedirs('artifacts', exist_ok=True)
    model_path = os.path.join('artifacts', f'{best_name}.pkl')
    joblib.dump(best_est, model_path)
    mlflow.log_artifact(model_path, artifact_path=best_name)
    
    print(f"Modelo: {best_name} | MAE={mae:.4f}  RMSE={rmse:.4f}  R2={r2:.4f} | fit {dt:.1f}s")
    print(f"Modelo registrado en MLflow con run_id: {mlflow.active_run().info.run_id}")