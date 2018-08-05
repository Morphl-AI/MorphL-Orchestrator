export TEMPFILE=$(mktemp)
python /opt/orchestrator/bootstrap/runasairflow/python/load_historical_data.py ${TEMPFILE}
rc=$?
if [ ${rc} -eq 0 ]; then
  echo "Emptying the relevant Cassandra tables ..."
  echo
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/orchestrator/bootstrap/runasairflow/cql/truncate_ga_churned_users_tables.cql
  echo "Initiating the data load ..."
  echo
  stop_airflow.sh
  airflow resetdb -y &>/dev/null
  START_DATE_AS_PY_CODE=$(<${TEMPFILE})
  echo "sed 's/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g' /opt/orchestrator/bootstrap/runasairflow/templates/ga_churned_users_dag.py.template" | bash > /home/airflow/airflow/dags/ga_churned_users_dag.py
  start_airflow.sh
  echo "The data load has been initiated."
  echo
fi
