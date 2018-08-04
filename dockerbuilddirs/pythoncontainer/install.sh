apt update -qq
apt -y install locales
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen en_US en_US.UTF-8 > /dev/null
update-locale LANG=en_US.UTF-8
apt -y install \
  wget curl git vim bzip2 jq mc net-tools less tmux sqlite3 sudo ca-certificates
bash /opt/Anaconda.sh -b -p /opt/anaconda
rm /opt/Anaconda.sh
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install oauth2client google-api-python-client tensorflow cassandra-driver
echo 'Building container, this may take a while ...'
