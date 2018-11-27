export TEMPFILE_A=$(mktemp)
export TEMPFILE_B=$(mktemp)
export TEMPFILE_C=$(mktemp)
python /opt/ga_chp_bq/ingestion/pipeline_setup/ga_chp_bq_load_historical_data.py ${TEMPFILE_A} ${TEMPFILE_B} ${TEMPFILE_C}
rc=$?
if [ ${rc} -eq 0 ]; then
  echo 'Emptying the relevant Cassandra tables ...'
  echo
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/ga_chp_bq/ingestion/pipeline_setup/ga_chp_bq_truncate_tables_before_loading_historical_data.cql
  DAYS_WORTH_OF_DATA_TO_LOAD=$(<${TEMPFILE_C})
  sed "s/DAYS_WORTH_OF_DATA_TO_LOAD/${DAYS_WORTH_OF_DATA_TO_LOAD}/g" /opt/ga_chp_bq/ingestion/pipeline_setup/insert_into_ga_chp_bq_config_parameters.cql.template > /tmp/insert_into_config_parameters.cql
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /tmp/insert_into_config_parameters.cql
  echo 'Initiating the data load ...'
  echo
  stop_airflow.sh
  rm -rf /home/airflow/airflow/dags/*
  airflow resetdb -y &>/dev/null
  python /opt/orchestrator/bootstrap/runasairflow/python/set_up_airflow_authentication.py
  START_DATE_AS_PY_CODE=$(<${TEMPFILE_A})
  sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/ga_chp_bq/ingestion/pipeline_setup/ga_chp_bq_ingestion_airflow_dag.py.template > /home/airflow/airflow/dags/ga_chp_bq_ingestion_pipeline.py
#   START_DATE_AS_PY_CODE=$(<${TEMPFILE_B})
#   sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/ga_chp_bq/training/pipeline_setup/ga_chp_bq_training_airflow_dag.py.template > /home/airflow/airflow/dags/ga_chp_bq_training_pipeline.py
#   sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/ga_chp_bq/prediction/pipeline_setup/ga_chp_bq_prediction_airflow_dag.py.template > /home/airflow/airflow/dags/ga_chp_bq_prediction_pipeline.py
#   start_airflow.sh
#   echo 'The data load has been initiated.'
  echo
fi
