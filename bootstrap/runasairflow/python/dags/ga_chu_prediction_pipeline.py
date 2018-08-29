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

try:
    with open('/tmp/ga_chu_prediction_pipeline_day_as_str.txt', 'r') as f:
        day_as_str = f.read().strip()
except:
    day_as_str = ''

try:
    with open('/tmp/ga_chu_prediction_pipeline_unique_hash.txt', 'r') as f:
        unique_hash = f.read().strip()
except:
    unique_hash = ''

# Do not remove the extra space at the end (the one after 'generate_id_files_prediction.sh')
task_1_generate_id_files_prediction = BashOperator(
    task_id='task_1_generate_id_files_prediction',
    bash_command='bash /opt/orchestrator/bootstrap/runasairflow/bash/generate_id_files_prediction.sh ',
    dag=dag)

# Do not remove the extra space at the end (the one after 'runpysparkpreprocessor.sh')
task_2_run_pyspark_preprocessor_cmd_parts = [
    f'DAY_AS_STR={day_as_str}',
    f'UNIQUE_HASH={unique_hash}',
    'TRAINING_OR_PREDICTION=prediction',
    'MODELS_DIR=/opt/models',
    'docker run --rm',
    '-v /opt/samplecode:/opt/samplecode',
    '-v /opt/models:/opt/models',
    '-e ENVIRONMENT_TYPE',
    '-e DAY_AS_STR',
    '-e UNIQUE_HASH',
    '-e TRAINING_OR_PREDICTION',
    '-e MODELS_DIR',
    '-e MORPHL_SERVER_IP_ADDRESS',
    '-e MORPHL_CASSANDRA_USERNAME',
    '-e MORPHL_CASSANDRA_KEYSPACE',
    '-e MORPHL_CASSANDRA_PASSWORD',
    'pysparkcontainer',
    'bash /opt/samplecode/python/pyspark/runpysparkpreprocessor.sh ']
task_2_run_pyspark_preprocessor_cmd = ' '.join(task_2_run_pyspark_preprocessor_cmd_parts)

task_2_run_pyspark_preprocessor = BashOperator(
    task_id='task_2_run_pyspark_preprocessor',
    bash_command=task_2_run_pyspark_preprocessor_cmd,
    dag=dag)

task_2_run_pyspark_preprocessor.set_upstream(task_1_generate_id_files_prediction)
