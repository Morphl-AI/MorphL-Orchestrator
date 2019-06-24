airflow_scheduler scheduler 1>/home/airflow/airflow/logs/scheduler_out.log 2>/home/airflow/airflow/logs/scheduler_err.log &
airflow_webserver webserver -p 8181 &>/dev/null &
sleep 1

