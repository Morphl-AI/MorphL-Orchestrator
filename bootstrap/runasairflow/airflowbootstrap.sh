set -e

mkdir /home/airflow/.kube
cat /etc/kubernetes/admin.conf > /home/airflow/.kube/config

mkdir /opt/{secrets,tmp}
touch /opt/secrets/keyfile.json

SP_CASS_CONN_VERSION=2.3.1

echo 'Setting up Anaconda ...'
ANACONDA_SH_URL=$(lynx -dump https://repo.continuum.io/archive/ | grep -o http.*Anaconda3.*Linux.x86_64.sh$ | head -1)
echo "From ${ANACONDA_SH_URL}"
wget -qO /opt/dockerbuilddirs/pythoncontainer/Anaconda.sh ${ANACONDA_SH_URL}
bash /opt/dockerbuilddirs/pythoncontainer/Anaconda.sh -b -p /opt/anaconda
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install psycopg2-binary apache-airflow Flask-Bcrypt cassandra-driver

echo 'Setting up the JDK ...'
JDK_TGZ_URL=$(lynx -dump https://www.azul.com/downloads/zulu/zulu-linux/ | grep -o http.*jdk8.*x64.*gz$ | head -1)
echo "From ${JDK_TGZ_URL}"
wget -qO /opt/tmp/zzzjdk.tgz ${JDK_TGZ_URL}
tar -xf /opt/tmp/zzzjdk.tgz -C /opt
mv /opt/zulu* /opt/jdk
rm /opt/tmp/zzzjdk.tgz

CLOSER="https://www.apache.org/dyn/closer.cgi?as_json=1"
MIRROR=$(curl --stderr /dev/null ${CLOSER} | jq -r '.preferred')

echo 'Setting up Spark ...'
SPARK_DIR_URL=$(lynx -dump ${MIRROR}spark/ | grep -o http.*spark-2.*$ | tail -1)
SPARK_TGZ_URL=$(lynx -dump ${SPARK_DIR_URL} | grep -o http.*bin-hadoop.*tgz$ | tail -1)
echo "From ${SPARK_TGZ_URL}"
wget -qO /opt/tmp/zzzspark.tgz ${SPARK_TGZ_URL}
tar -xf /opt/tmp/zzzspark.tgz -C /opt
mv /opt/spark-* /opt/spark
rm /opt/tmp/zzzspark.tgz
cd /opt/spark/conf
sed 's/INFO/FATAL/;s/WARN/FATAL/;s/ERROR/FATAL/' log4j.properties.template > log4j.properties

wget -qO /opt/spark/jars/spark-cassandra-connector.jar https://repo1.maven.org/maven2/com/datastax/spark/spark-cassandra-connector_2.11/${SP_CASS_CONN_VERSION}/spark-cassandra-connector_2.11-${SP_CASS_CONN_VERSION}.jar

echo 'Setting up Hadoop ...'
HADOOP_TGZ_URL=$(lynx -dump ${MIRROR}hadoop/common/stable/ | grep -o http.*gz$ | grep -v src | head -1)
echo "From ${HADOOP_TGZ_URL}"
wget -qO /opt/tmp/zzzhadoop.tgz ${HADOOP_TGZ_URL}
tar -xf /opt/tmp/zzzhadoop.tgz -C /opt
mv /opt/hadoop-* /opt/hadoop
rm /opt/tmp/zzzhadoop.tgz

echo 'Setting up Cassandra ...'
CASSANDRA_DIR_URL=$(lynx -dump ${MIRROR}cassandra/ | grep -o http.*cassandra/3.*$ | tail -1)
CASSANDRA_TGZ_URL=$(lynx -dump ${CASSANDRA_DIR_URL} | grep -o http.*bin.tar.gz$ | head -1)
echo "From ${CASSANDRA_TGZ_URL}"
wget -qO /opt/tmp/cassandra.tgz ${CASSANDRA_TGZ_URL}
tar -xf /opt/tmp/cassandra.tgz -C /opt
mv /opt/apache-cassandra-* /opt/cassandra
rm /opt/tmp/cassandra.tgz
cp /opt/orchestrator/bootstrap/runasairflow/bash/cassandra/*_cassandra.sh /opt/cassandra/bin/
echo "sed 's/MORPHL_SERVER_IP_ADDRESS/${MORPHL_SERVER_IP_ADDRESS}/g' /opt/orchestrator/bootstrap/runasairflow/templates/cassandra.yaml.template" | bash > /opt/cassandra/conf/cassandra.yaml
start_cassandra.sh
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u cassandra -p cassandra -e "CREATE USER morphl WITH PASSWORD '${MORPHL_CASSANDRA_PASSWORD}' SUPERUSER;"
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u cassandra -p cassandra -e "ALTER USER cassandra WITH PASSWORD '${NONDEFAULT_SUPERUSER_CASSANDRA_PASSWORD}';"
cqlsh ${MORPHL_SERVER_IP_ADDRESS} -u morphl -p ${MORPHL_CASSANDRA_PASSWORD} -f /opt/orchestrator/bootstrap/runasairflow/cql/cassandra_schema.cql

mkdir -p /home/airflow/airflow/dags
cat /opt/orchestrator/bootstrap/runasairflow/templates/airflow.cfg.template > /home/airflow/airflow/airflow.cfg
cp /opt/anaconda/bin/airflow /opt/anaconda/bin/airflow_scheduler
cp /opt/anaconda/bin/airflow /opt/anaconda/bin/airflow_webserver
cp /opt/orchestrator/bootstrap/runasairflow/bash/airflow/*_airflow.sh /opt/anaconda/bin/
airflow version
airflow initdb
python /opt/orchestrator/bootstrap/runasairflow/python/set_up_airflow_authentication.py
start_airflow.sh

cp /opt/orchestrator/bootstrap/runasairflow/bash/load_historical_data.sh /opt/anaconda/bin/

cd /opt/orchestrator && sudo git pull
sudo cp /opt/orchestrator/dockerbuilddirs/pythoncontainer/Dockerfile /opt/dockerbuilddirs/pythoncontainer/Dockerfile
sudo cp /opt/orchestrator/dockerbuilddirs/pythoncontainer/install.sh /opt/dockerbuilddirs/pythoncontainer/install.sh
cd /opt/dockerbuilddirs/pythoncontainer
docker build -t pythoncontainer .
