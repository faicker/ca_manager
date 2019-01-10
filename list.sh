#!/usr/bin/env bash

cd `dirname ${BASH_SOURCE[0]}`
. common.def

list_server() {
    local server=$1
    CLIENTS_DIR=$OPENVPN_DIR/$ca/servers/$server/client-configs
    if [[ -d $CLIENTS_DIR ]]; then
        for client in `ls -1 $CLIENTS_DIR`; do
            if [[ -d $CLIENTS_DIR/$client ]]; then
                echo "    $client($CLIENTS_DIR/$client.zip)"
            fi
        done
    fi
}

list_ca() {
    local ca=$1
    SERVERS_DIR=$OPENVPN_DIR/$ca/servers
    if [[ -d $SERVERS_DIR ]]; then
        for server in `ls -1 $SERVERS_DIR`; do
            if [[ -d $SERVERS_DIR/$server ]]; then
                echo "  $server($SERVERS_DIR/$server.zip)"
                list_server $server
            fi
        done
    fi
}

for ca_name in `ls -1 $OPENVPN_DIR`; do
    echo "$ca_name"
    list_ca $ca_name
    echo "============================="
done
