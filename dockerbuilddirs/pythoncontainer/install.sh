export DEBIAN_FRONTEND=noninteractive
apt update -qq &>/dev/null
apt -y install locales apt-utils &>/dev/null
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen > /dev/null
update-locale LANG=en_US.UTF-8
apt -y install wget curl git vim bzip2 jq mc lynx net-tools less tmux sqlite3 sudo ca-certificates build-essential binutils python2.7-minimal &>/dev/null
bash /opt/Anaconda.sh -b -p /opt/anaconda
rm /opt/Anaconda.sh
mv /opt/anaconda/bin/sqlite3 /opt/anaconda/bin/sqlite3.orig
pip install msgpack
pip install --upgrade pip
pip install google-auth
pip install google-api-python-client
# Install tensorflow wrap dependency first to prevent distutils uninstall error
pip install wrapt --ignore-installed
pip install tensorflow
pip install keras
pip install cassandra-driver
pip install PyJWT
pip install flask-cors
pip install torch
pip install torchtext
pip install pyarrow==0.13.0
pip install gcsfs==0.2.0
conda install fastparquet h5py==2.8.0 -y -c conda-forge
conda install python-snappy -y
wget -qO /opt/gcsdk.tgz https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
tar -xf /opt/gcsdk.tgz -C /opt
rm /opt/gcsdk.tgz
mv /opt/google-cloud-sdk /opt/gcsdk
/opt/gcsdk/install.sh --quiet --usage-reporting=false &>/dev/null
echo 'Building container 1 (out of 2), this may take a while ...'