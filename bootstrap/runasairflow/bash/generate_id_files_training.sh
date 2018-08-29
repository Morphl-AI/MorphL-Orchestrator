TODAY_AS_STR=$(date +"%Y-%m-%d")
UNIQUE_HASH=$(openssl rand -hex 64 | cut -c1-20)
IS_MODEL_VALID=False
echo ${TODAY_AS_STR} > /tmp/ga_chu_training_pipeline_today_as_str.txt
echo ${UNIQUE_HASH} > /tmp/ga_chu_training_pipeline_unique_hash.txt
sed "s/TODAY_AS_STR/${TODAY_AS_STR}/;s/UNIQUE_HASH/${UNIQUE_HASH}/;s/IS_MODEL_VALID/${IS_MODEL_VALID}/" /opt/orchestrator/bootstrap/runasairflow/cql/insert_into_valid_models.cql.template > /tmp/ga_chu_training_pipeline_insert_into_valid_models.cql
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /tmp/ga_chu_training_pipeline_insert_into_valid_models.cql
