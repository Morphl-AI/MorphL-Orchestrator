import datetime
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator

args = { 'owner': 'airflow',
         'start_date': datetime.datetime(9999, 12, 31, 23, 59, 59, 999999),
         'retries': 16,
         'retry_delay': datetime.timedelta(minutes=30) }

dag = DAG(dag_id='ga_chu_prediction_pipeline',
          default_args=args,
          schedule_interval='@daily')
