from __future__ import annotations
import pendulum

from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator

# Nombre del DAG y configuración de la fecha de inicio
with DAG(
    dag_id="entrenamiento_modelo_ml",
    start_date=pendulum.datetime(2025, 9, 16, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=["mlops", "mlflow", "train"],
) as dag:
    
    # Define la tarea principal que ejecutará tu script de Python
    train_model = BashOperator(
        task_id="ejecutar_entrenamiento",
        bash_command="python /opt/airflow/scripts/train_model.py"
    )