bash /opt/tmp/Anaconda.sh -b -p /opt/anaconda
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install oauth2client google-api-python-client tensorflow cassandra-driver

