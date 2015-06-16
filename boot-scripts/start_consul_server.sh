#!/bin/bash

cat <<EOF > /opt/start_consul.sh
#!/bin/sh

if ! ps -fwwe | grep -q "[c]onsul agent"; then
    source /etc/profile
    nohup /bin/consul agent -config-dir /etc/consul/ &
fi

EOF
chmod +x /opt/start_consul.sh

echo "* * * * * /opt/start_consul.sh" | crontab
