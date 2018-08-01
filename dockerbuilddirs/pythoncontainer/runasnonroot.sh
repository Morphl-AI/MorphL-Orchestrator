bash /opt/Anaconda.sh -b -p /opt/anaconda
rm /opt/Anaconda.sh
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install oauth2client google-api-python-client tensorflow cassandra-driver
echo 'Building container, this may take a while ...'
