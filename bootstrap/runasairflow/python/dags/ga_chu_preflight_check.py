import datetime
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator

args = { 'owner': 'airflow',
         'start_date': datetime.datetime(9999, 12, 31, 23, 59, 59, 999999),
         'retries': 16,
         'retry_delay': datetime.timedelta(minutes=30) }

dag = DAG(dag_id='ga_chu_preflight_check',
          default_args=args,
          schedule_interval='0 18 * * *')

# Do not remove the extra space at the end (the one after 'preflight_check_before_prediction_pipeline.sh')
task_1_preflight_check_before_prediction_pipeline = BashOperator(
    task_id='task_1_preflight_check_before_prediction_pipeline',
    bash_command='bash /opt/orchestrator/bootstrap/runasairflow/bash/preflight_check_before_prediction_pipeline.sh ',
    dag=dag)
