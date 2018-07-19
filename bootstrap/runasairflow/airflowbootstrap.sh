mkdir /home/airflow/.kube
cat /etc/kubernetes/admin.conf > /home/airflow/.kube/config

mkdir /opt/tmp

ANACONDA_VERSION=5.2.0
SPARK_VERSION=2.3.1
CASSANDRA_VERSION=3.11.2
SP_CASS_CONN_VERSION=2.3.1

wget -qO /opt/tmp/Anaconda.sh https://repo.continuum.io/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh
bash /opt/tmp/Anaconda.sh -b -p /opt/anaconda
rm /opt/tmp/Anaconda.sh
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install psycopg2-binary apache-airflow

wget -qO /opt/tmp/zzzjdk.tgz https://cdn.azul.com/zulu/bin/zulu8.30.0.1-jdk8.0.172-linux_x64.tar.gz
tar -xf /opt/tmp/zzzjdk.tgz -C /opt
mv /opt/zulu* /opt/jdk
rm /opt/tmp/zzzjdk.tgz

CLOSER="https://www.apache.org/dyn/closer.cgi?as_json=1"
MIRROR=$(curl --stderr /dev/null ${CLOSER} | jq -r '.preferred')

wget -qO /opt/tmp/zzzspark.tgz ${MIRROR}spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz
tar -xf /opt/tmp/zzzspark.tgz -C /opt
mv /opt/spark-* /opt/spark
rm /opt/tmp/zzzspark.tgz
cd /opt/spark/conf
sed 's/INFO/FATAL/;s/WARN/FATAL/;s/ERROR/FATAL/' log4j.properties.template > log4j.properties

wget -qO /opt/spark/jars/spark-cassandra-connector.jar https://repo1.maven.org/maven2/com/datastax/spark/spark-cassandra-connector_2.11/${SP_CASS_CONN_VERSION}/spark-cassandra-connector_2.11-${SP_CASS_CONN_VERSION}.jar

HADOOP_TGZ_URL=$(lynx -dump ${MIRROR}/hadoop/common/stable/ | grep -o http.*gz$ | grep -v src)
wget -qO /opt/tmp/zzzhadoop.tgz ${HADOOP_TGZ_URL}
tar -xf /opt/tmp/zzzhadoop.tgz -C /opt
mv /opt/hadoop-* /opt/hadoop
rm /opt/tmp/zzzhadoop.tgz

wget -qO /opt/tmp/cassandra.tgz ${MIRROR}cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz
tar -xf /opt/tmp/cassandra.tgz -C /opt
mv /opt/apache-cassandra-* /opt/cassandra
rm /opt/tmp/cassandra.tgz
cp /opt/orchestrator/bootstrap/runasairflow/*_cassandra.sh /opt/cassandra/bin/
echo "sed 's/MORPHL_SERVER_IP_ADDRESS/${MORPHL_SERVER_IP_ADDRESS}/g' /opt/orchestrator/bootstrap/runasairflow/cassandra.yaml.template" | bash > /opt/cassandra/conf/cassandra.yaml
start_cassandra.sh
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u cassandra -p cassandra -e "CREATE USER morphl WITH PASSWORD '${MORPHL_CASSANDRA_PASSWORD}' SUPERUSER;"
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u cassandra -p cassandra -e "ALTER USER cassandra WITH PASSWORD '${NONDEFAULT_SUPERUSER_CASSANDRA_PASSWORD}';"
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/orchestrator/bootstrap/runasairflow/cassandra_schema.cql

mkdir -p /home/airflow/airflow/dags
cat /opt/orchestrator/bootstrap/runasairflow/airflow.cfg.template > /home/airflow/airflow/airflow.cfg
cp /opt/anaconda/bin/airflow /opt/anaconda/bin/airflow_scheduler
cp /opt/anaconda/bin/airflow /opt/anaconda/bin/airflow_webserver
cp /opt/orchestrator/bootstrap/runasairflow/*_airflow.sh /opt/anaconda/bin/
airflow version
airflow initdb
start_airflow.sh

