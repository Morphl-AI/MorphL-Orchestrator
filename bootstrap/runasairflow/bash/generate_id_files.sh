date +"%Y-%m-%d" > /tmp/today_as_str.txt
openssl rand -hex 64 | cut -c1-20 > /tmp/unique_hash.txt
