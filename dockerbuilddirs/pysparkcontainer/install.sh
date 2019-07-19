export DEBIAN_FRONTEND=noninteractive

mkdir /opt/tmp

#### Old repo ###
# SP_CASS_CONN_VERSION=2.4.1
# JSR166E_VERSION=1.1.0
# SPARK_AVRO_VERSION=2.4.1
#################

MORPHL_MIRROR='http://mirror.morphlio.com/repo'

echo 'Setting up the JDK ...'
#### Old repo ###
# JDK_TGZ_URL=$(lynx -dump https://www.azul.com/downloads/zulu/ | grep -o http.*jdk8.*linux_x64.*gz$ | head -1)
#################
#### New repo ###
JDK_TGZ_URL="${MORPHL_MIRROR}/jdk/jdk8.0.212-linux_x64.tar.gz"
#################
echo "From ${JDK_TGZ_URL}"
wget -qO /opt/tmp/zzzjdk.tgz ${JDK_TGZ_URL}
tar -xf /opt/tmp/zzzjdk.tgz -C /opt
mv /opt/zulu* /opt/jdk
rm /opt/tmp/zzzjdk.tgz

echo 'Setting up Spark ...'
#### Old repo ###
# CLOSER="https://www.apache.org/dyn/closer.cgi?as_json=1"
# MIRROR=$(curl --stderr /dev/null ${CLOSER} | jq -r '.preferred')
# SPARK_DIR_URL=$(lynx -dump ${MIRROR}spark/ | grep -o 'http.*/spark/spark-[0-9].*$' | sort -V | tail -1)
# SPARK_TGZ_URL=$(lynx -dump ${SPARK_DIR_URL} | grep -o http.*bin-hadoop.*tgz$ | tail -1)
#### Old repo ###
# SPARK_TGZ_URL='https://archive.apache.org/dist/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz'
#################
#### New repo ###
SPARK_TGZ_URL="${MORPHL_MIRROR}/apache-spark/spark-2.4.1-bin-hadoop2.7.tgz"
#################
echo "From ${SPARK_TGZ_URL}"
wget -qO /opt/tmp/zzzspark.tgz ${SPARK_TGZ_URL}
tar -xf /opt/tmp/zzzspark.tgz -C /opt
mv /opt/spark-* /opt/spark
rm /opt/tmp/zzzspark.tgz
cd /opt/spark/conf
sed 's/INFO/FATAL/;s/WARN/FATAL/;s/ERROR/FATAL/' log4j.properties.template > log4j.properties

#### Old repo ###
# wget -qO /opt/spark/jars/spark-cassandra-connector.jar https://repo1.maven.org/maven2/com/datastax/spark/spark-cassandra-connector_2.11/${SP_CASS_CONN_VERSION}/spark-cassandra-connector_2.11-${SP_CASS_CONN_VERSION}.jar
# wget -qO /opt/spark/jars/jsr166e.jar https://repo1.maven.org/maven2/com/twitter/jsr166e/${JSR166E_VERSION}/jsr166e-${JSR166E_VERSION}.jar
# wget -qO /opt/spark/jars/spark-avro.jar https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.11/${SPARK_AVRO_VERSION}/spark-avro_2.11-${SPARK_AVRO_VERSION}.jar
#################
#### New repo ###
wget -qO /opt/spark/jars/spark-cassandra-connector.jar "${MORPHL_MIRROR}/apache-spark/connectors/spark-cassandra-connector_2.11-2.4.1.jar"
wget -qO /opt/spark/jars/jsr166e.jar "${MORPHL_MIRROR}/apache-spark/connectors/jsr166e-1.1.0.jar"
wget -qO /opt/spark/jars/spark-avro.jar "${MORPHL_MIRROR}/apache-spark/connectors/spark-avro_2.11-2.4.1.jar"
#################

echo 'Setting up Hadoop ...'
#### Old repo ###
# HADOOP_TGZ_URL=$(lynx -dump ${MIRROR}hadoop/common/stable/ | grep -o http.*gz$ | grep -v src | grep -v site | head -1)
#################
#### New repo ###
HADOOP_TGZ_URL="${MORPHL_MIRROR}/apache-hadoop/hadoop-3.2.0.tar.gz"
#################
echo "From ${HADOOP_TGZ_URL}"
wget -qO /opt/tmp/zzzhadoop.tgz ${HADOOP_TGZ_URL}
tar -xf /opt/tmp/zzzhadoop.tgz -C /opt
mv /opt/hadoop-* /opt/hadoop
rm /opt/tmp/zzzhadoop.tgz

echo 'Building container 2 (out of 2), this may take a while ...'
