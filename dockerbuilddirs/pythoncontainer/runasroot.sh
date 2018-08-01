apt update -qq
apt -y install \
  wget curl git vim bzip2 jq mc net-tools less tmux sqlite3 locales sudo ca-certificates
useradd -m developer
chmod -R 775 /opt
chgrp -R developer /opt
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen > /dev/null

