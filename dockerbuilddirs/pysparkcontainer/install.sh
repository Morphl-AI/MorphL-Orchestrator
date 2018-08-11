export DEBIAN_FRONTEND=noninteractive

mkdir /opt/tmp

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
SPARK_DIR_URL=$(lynx -dump ${MIRROR}spark/ | grep -o 'http.*/spark/spark-[0-9].*$' | sort -V | tail -1)
SPARK_TGZ_URL=$(lynx -dump ${SPARK_DIR_URL} | grep -o http.*bin-hadoop.*tgz$ | tail -1)
echo "From ${SPARK_TGZ_URL}"
wget -qO /opt/tmp/zzzspark.tgz ${SPARK_TGZ_URL}
tar -xf /opt/tmp/zzzspark.tgz -C /opt
mv /opt/spark-* /opt/spark
rm /opt/tmp/zzzspark.tgz
cd /opt/spark/conf
sed 's/INFO/FATAL/;s/WARN/FATAL/;s/ERROR/FATAL/' log4j.properties.template > log4j.properties

echo 'Setting up Hadoop ...'
HADOOP_TGZ_URL=$(lynx -dump ${MIRROR}hadoop/common/stable/ | grep -o http.*gz$ | grep -v src | head -1)
echo "From ${HADOOP_TGZ_URL}"
wget -qO /opt/tmp/zzzhadoop.tgz ${HADOOP_TGZ_URL}
tar -xf /opt/tmp/zzzhadoop.tgz -C /opt
mv /opt/hadoop-* /opt/hadoop
rm /opt/tmp/zzzhadoop.tgz

echo 'Building container, this may take a while ...'
