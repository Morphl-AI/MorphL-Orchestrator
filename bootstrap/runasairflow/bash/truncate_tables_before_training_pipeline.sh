cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/orchestrator/bootstrap/runasairflow/cql/truncate_tables_before_training_pipeline.cql
