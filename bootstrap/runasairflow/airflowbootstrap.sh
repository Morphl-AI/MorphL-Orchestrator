mkdir /home/airflow/.kube
cat /etc/kubernetes/admin.conf > /home/airflow/.kube/config

wget -qO /opt/tmp/Anaconda.sh https://repo.continuum.io/archive/Anaconda3-5.2.0-Linux-x86_64.sh
bash /opt/tmp/Anaconda.sh -b -u -p /opt/anaconda
rm /opt/tmp/Anaconda.sh
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install psycopg2-binary apache-airflow
mkdir -p /home/airflow/airflow/dags
cat /opt/orchestrator/bootstrap/runasairflow/airflow.cfg.template > /home/airflow/airflow/airflow.cfg
airflow version
airflow initdb

