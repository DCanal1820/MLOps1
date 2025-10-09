'''
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
'''

from __future__ import annotations
import pendulum
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator

# Importar tu función de entrenamiento
# Asegurate que train_model.py esté en el PYTHONPATH o mismo directorio
from scripts.train_model import main as train_model_func

with DAG(
    dag_id="entrenamiento_modelo_ml",
    start_date=pendulum.datetime(2025, 9, 16, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=["mlops", "mlflow", "train"],
) as dag:

    ejecutar_entrenamiento = PythonOperator(
        task_id="ejecutar_entrenamiento",
        python_callable=train_model_func
    )
