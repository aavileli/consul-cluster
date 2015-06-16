#!/bin/bash

region="$(curl -sL 169.254.169.254/latest/meta-data/placement/availability-zone | sed '$s/.$//')"
my_ipaddress="$(curl -sL 169.254.169.254/latest/meta-data/local-ipv4)"

addresses="$(python ./lib/group_addresses.py)"
## lets wait until the minimum actually exists
while [ "$(wc -l < <(echo $addresses | perl -pe 's{\s}{\n}g'))" -lt "${CONSUL_GROUP_SIZE_MIN:-0}" ]; do
    sleep 1
    addresses="$(python ./lib/group_addresses.py)"
done

failed_consul_nodes="$(/bin/consul members | grep failed | awk '{print $1}')"

## lets give it some time
sleep "${CONSUL_FAILURE_GRACE_PERIOD_IN_SECONDS:-60}"

for node in $failed_consul_nodes; do
    ## if they are still failed, kill them
    failed_node_address="$(/bin/consul members | grep $node | grep failed | awk '{print $2}')"
    if [ -n "$failed_node_address" ]; then
        /bin/consul force-leave "$(echo $failed_node_address | awk -F':' '{print $1}'):8400"
    fi
done
