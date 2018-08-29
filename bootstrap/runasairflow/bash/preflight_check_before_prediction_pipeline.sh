cql_stmt='SELECT is_model_valid FROM morphl.ga_churned_users_valid_models WHERE always_zero = 0 AND is_model_valid = True LIMIT 1 ALLOW FILTERING;'
echo ${cql_stmt} | \
  cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} | \
  grep True && \
    airflow trigger_dag ga_chu_prediction_pipeline
