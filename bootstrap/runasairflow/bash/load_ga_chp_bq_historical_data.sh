# TEMPFILE_A is the training window delay (difference between end date and today)
export TEMPFILE_A=$(mktemp)
# TEMPFILE_B is the duration of the training interval in days
export TEMPFILE_B=$(mktemp)
# TEMPFILE_C is the Python start date (today)
export TEMPFILE_C=$(mktemp)

python /opt/ga_chp_bq/training/pipeline_setup/ga_chp_bq_load_historical_data.py ${TEMPFILE_A} ${TEMPFILE_B} ${TEMPFILE_C}
rc=$?
if [ ${rc} -eq 0 ]; then
  echo 'Emptying the relevant Cassandra tables ...'
  echo
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/ga_chp_bq/training/pipeline_setup/ga_chp_bq_truncate_tables_before_training_pipeline.cql

  # Write configuration parameters in corresponding Cassandra table
  DAYS_TRAINING_DELAY=$(<${TEMPFILE_A})
  DAYS_WORTH_OF_DATA_TO_LOAD=$(<${TEMPFILE_B})
  sed "s/DAYS_TRAINING_DELAY/${DAYS_TRAINING_DELAY}/g;S/DAYS_WORTH_OF_DATA_TO_LOAD/${DAYS_WORTH_OF_DATA_TO_LOAD}/g" /opt/ga_chp_bq/training/pipeline_setup/insert_into_ga_chp_bq_config_parameters.cql.template > /tmp/insert_into_config_parameters.cql
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /tmp/insert_into_config_parameters.cql

  # Reset Airflow and create dags
  echo 'Initiating the data load ...'
  echo
  stop_airflow.sh
  rm -rf /home/airflow/airflow/dags/*
  airflow resetdb -y &>/dev/null
  python /opt/orchestrator/bootstrap/runasairflow/python/set_up_airflow_authentication.py
  START_DATE_AS_PY_CODE=$(<${TEMPFILE_C})
  sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/ga_chp_bq/training/pipeline_setup/ga_chp_bq_training_airflow_dag.py.template > /home/airflow/airflow/dags/ga_chp_bq_training_pipeline.py
#   START_DATE_AS_PY_CODE=$(<${TEMPFILE_C})
#   sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/ga_chp_bq/prediction/pipeline_setup/ga_chp_bq_prediction_airflow_dag.py.template > /home/airflow/airflow/dags/ga_chp_bq_prediction_pipeline.py
  start_airflow.sh
  echo 'The data load has been initiated.'
  echo
fi
