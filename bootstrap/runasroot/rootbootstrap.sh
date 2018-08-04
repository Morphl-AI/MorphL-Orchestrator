set -e

apt -y install docker.io apt-transport-https curl
echo 'DOCKER_OPTS="--insecure-registry localhost:5000"' > /etc/default/docker
service docker restart
docker pull registry:2
docker run -d --name registry --restart=always    \
           -p 127.0.0.1:5000:5000                 \
           -v /var/lib/registry:/var/lib/registry \
           registry:2

STABLE_KUBERNETES_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update -qq && apt -y install kubelet kubeadm kubectl
kubeadm config images pull --kubernetes-version=${STABLE_KUBERNETES_VERSION}
kubeadm init --kubernetes-version=${STABLE_KUBERNETES_VERSION} --pod-network-cidr=10.244.0.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf
echo -e '\nexport KUBECONFIG=/etc/kubernetes/admin.conf' >> /root/.bashrc
chmod g+r /etc/kubernetes/admin.conf
chgrp sudo /etc/kubernetes/admin.conf
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master-

apt -y install build-essential binutils ntp openssl sudo wget lynx htop nethogs tmux jq
apt -y install postgresql postgresql-contrib postgresql-client postgresql-client-common
sudo -Hiu postgres psql -c "CREATE USER airflow PASSWORD 'airflow';"
sudo -Hiu postgres psql -c "CREATE DATABASE airflow;"
sudo -Hiu postgres psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow;"
sudo -Hiu postgres psql -c "CREATE USER morphl PASSWORD 'morphl';"
sudo -Hiu postgres psql -c "CREATE DATABASE morphl;"
sudo -Hiu postgres psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO morphl;"

cat /opt/orchestrator/bootstrap/runasroot/rc.local > /etc/rc.local

MORPHL_SERVER_IP_ADDRESS=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
AIRFLOW_OS_PASSWORD=$(openssl rand -base64 32 | sha512sum | cut -c1-20)
AIRFLOW_WEB_UI_PASSWORD=$(openssl rand -base64 32 | sha512sum | cut -c1-20)
MORPHL_OS_PASSWORD=$(openssl rand -base64 32 | sha512sum | cut -c1-20)
MORPHL_CASSANDRA_PASSWORD=$(openssl rand -base64 32 | sha512sum | cut -c1-20)
NONDEFAULT_SUPERUSER_CASSANDRA_PASSWORD=$(openssl rand -base64 32 | sha512sum | cut -c1-20)

useradd -m airflow
echo "airflow:${AIRFLOW_OS_PASSWORD}" | chpasswd
usermod -aG docker,sudo airflow

useradd -m morphl
echo "morphl:${MORPHL_OS_PASSWORD}" | chpasswd
usermod -aG docker,sudo morphl

touch /home/airflow/.profile /home/airflow/.morphl_environment.sh /home/airflow/.morphl_secrets.sh
chmod 660 /home/airflow/.profile /home/airflow/.morphl_environment.sh /home/airflow/.morphl_secrets.sh
chown airflow /home/airflow/.profile /home/airflow/.morphl_environment.sh /home/airflow/.morphl_secrets.sh
echo "airflow ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "morphl ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "export MORPHL_SERVER_IP_ADDRESS=${MORPHL_SERVER_IP_ADDRESS}" >> /home/airflow/.morphl_environment.sh
echo "export AIRFLOW_HOME=/home/airflow/airflow" >> /home/airflow/.morphl_environment.sh
echo "export JAVA_HOME=/opt/jdk" >> /home/airflow/.morphl_environment.sh
echo "export SPARK_HOME=/opt/spark" >> /home/airflow/.morphl_environment.sh
echo "export LD_LIBRARY_PATH=/opt/hadoop/lib/native:\$LD_LIBRARY_PATH" >> /home/airflow/.morphl_environment.sh
echo "export PATH=/opt/anaconda/bin:/opt/jdk/bin:/opt/spark/bin:/opt/cassandra/bin:\$PATH" >> /home/airflow/.morphl_environment.sh
echo "export AIRFLOW_OS_PASSWORD=${AIRFLOW_OS_PASSWORD}" >> /home/airflow/.morphl_secrets.sh
echo "export AIRFLOW_WEB_UI_PASSWORD=${AIRFLOW_WEB_UI_PASSWORD}" >> /home/airflow/.morphl_secrets.sh
echo "export MORPHL_OS_PASSWORD=${MORPHL_OS_PASSWORD}" >> /home/airflow/.morphl_secrets.sh
echo "export MORPHL_CASSANDRA_PASSWORD=${MORPHL_CASSANDRA_PASSWORD}" >> /home/airflow/.morphl_secrets.sh
echo "export NONDEFAULT_SUPERUSER_CASSANDRA_PASSWORD=${NONDEFAULT_SUPERUSER_CASSANDRA_PASSWORD}" >> /home/airflow/.morphl_secrets.sh
echo ". /home/airflow/.morphl_environment.sh" >> /home/airflow/.profile
echo ". /home/airflow/.morphl_secrets.sh" >> /home/airflow/.profile

mkdir -p /opt/dockerbuilddirs/pythoncontainer
chmod 775 /opt
chmod -R 775 /opt/dockerbuilddirs
chgrp airflow /opt
chgrp -R airflow /opt/dockerbuilddirs

git clone https://github.com/Morphl-Project/Sample-Code /opt/samplecode

sudo -Hiu airflow bash -c /opt/orchestrator/bootstrap/runasairflow/airflowbootstrap.sh
