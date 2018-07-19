airflow_scheduler scheduler > /dev/null 2>/dev/null &
airflow_webserver webserver -p 8181 > /dev/null 2>/dev/null &
sleep 1

