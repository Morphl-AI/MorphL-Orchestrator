export TEMPFILE=$(mktemp)
python /opt/orchestrator/bootstrap/runasairflow/python/load_historical_data.py ${TEMPFILE}
rc=$?
if [ ${rc} -eq 0 ]; then
  START_DATE_AS_PY_CODE=$(<${TEMPFILE})
  stop_airflow.sh
  echo "sed 's/START_DATE_AS_PY_CODE/${START_DATE_AS_PY_CODE}/g' /opt/orchestrator/bootstrap/runasairflow/templates/ga_churned_users_dag.py.template" | bash > /home/airflow/airflow/dags/ga_churned_users_dag.py
  start_airflow.sh
fi
