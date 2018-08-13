export TEMPFILE_A=$(mktemp)
export TEMPFILE_B=$(mktemp)
export TEMPFILE_C=$(mktemp)
python /opt/orchestrator/bootstrap/runasairflow/python/load_historical_data.py ${TEMPFILE_A} ${TEMPFILE_B} ${TEMPFILE_C}
rc=$?
if [ ${rc} -eq 0 ]; then
  echo "Emptying the relevant Cassandra tables ..."
  echo
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/orchestrator/bootstrap/runasairflow/cql/truncate_ga_churned_users_tables.cql
  STEP_2_DAYS_WORTH_OF_DATA_TO_LOAD=$(<${TEMPFILE_C})
  sed "s/STEP_2_DAYS_WORTH_OF_DATA_TO_LOAD/${STEP_2_DAYS_WORTH_OF_DATA_TO_LOAD}/g" /opt/orchestrator/bootstrap/runasairflow/cql/insert_into_config_parameters.cql
  echo "Initiating the data load ..."
  echo
  stop_airflow.sh
  airflow resetdb -y &>/dev/null
  STEP_1_START_DATE_AS_PY_CODE=$(<${TEMPFILE_A})
  sed "s/STEP_1_START_DATE_AS_PY_CODE/${STEP_1_START_DATE_AS_PY_CODE}/g" /opt/orchestrator/bootstrap/runasairflow/python/dags/ga_churned_users_step_1_dag.py.template > /home/airflow/airflow/dags/ga_churned_users_step_1_dag.py
  STEP_2_START_DATE_AS_PY_CODE=$(<${TEMPFILE_B})
  sed "s/STEP_2_START_DATE_AS_PY_CODE/${STEP_2_START_DATE_AS_PY_CODE}/g" /opt/orchestrator/bootstrap/runasairflow/python/dags/ga_churned_users_step_2_dag.py.template > /home/airflow/airflow/dags/ga_churned_users_step_2_dag.py
  start_airflow.sh
  echo "The data load has been initiated."
  echo
fi
