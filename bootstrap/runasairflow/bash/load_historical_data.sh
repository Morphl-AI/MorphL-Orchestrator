export TEMPFILE_A=$(mktemp)
export TEMPFILE_B=$(mktemp)
export TEMPFILE_C=$(mktemp)
python /opt/orchestrator/bootstrap/runasairflow/python/load_historical_data.py ${TEMPFILE_A} ${TEMPFILE_B} ${TEMPFILE_C}
rc=$?
if [ ${rc} -eq 0 ]; then
  echo 'Emptying the relevant Cassandra tables ...'
  echo
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/orchestrator/bootstrap/runasairflow/cql/truncate_ga_chu_ingestion_tables.cql
  DAYS_WORTH_OF_DATA_TO_LOAD=$(<${TEMPFILE_C})
  sed "s/DAYS_WORTH_OF_DATA_TO_LOAD/${DAYS_WORTH_OF_DATA_TO_LOAD}/g" /opt/orchestrator/bootstrap/runasairflow/cql/insert_into_config_parameters.cql.template > /tmp/insert_into_config_parameters.cql
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /tmp/insert_into_config_parameters.cql
  echo 'Initiating the data load ...'
  echo
  stop_airflow.sh
  airflow resetdb -y &>/dev/null
  START_DATE_AS_PY_CODE=$(<${TEMPFILE_A})
  sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/orchestrator/bootstrap/runasairflow/python/dags/ga_chu_ingestion_pipeline.py.template > /home/airflow/airflow/dags/ga_chu_ingestion_pipeline.py
  START_DATE_AS_PY_CODE=$(<${TEMPFILE_B})
  sed "s/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g" /opt/orchestrator/bootstrap/runasairflow/python/dags/ga_chu_training_pipeline.py.template > /home/airflow/airflow/dags/ga_chu_training_pipeline.py
  start_airflow.sh
  echo 'The data load has been initiated.'
  echo
fi
