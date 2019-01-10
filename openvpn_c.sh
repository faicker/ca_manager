#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`
. common.def

ca_name=$1
server_name=$2
name=$3
ip=$4

if [[ $# -lt 4 ]]; then
    echo "usage: $0 ca_name server_name client_name server_ip"
    exit 1
fi


CA_DIR="$OPENVPN_DIR/$ca_name"
SERVERS_DIR="$CA_DIR/servers"
SERVER_DIR="$SERVERS_DIR/$server_name"
CLIENTS_DIR="$SERVER_DIR/client-configs"
CLIENT_DIR="$CLIENTS_DIR/$name"

if [[ ! -d $SERVER_DIR ]]; then
    echo "error, generate server first"
    exit 1
elif [[ -d $CLIENT_DIR ]]; then
    echo "error, client exist"
    exit 1
fi

server_conf=$SERVER_DIR/$server_name.conf
proto=$(grep '^proto' $server_conf | awk '{print $2}')
port=$(grep '^port' $server_conf | awk '{print $2}')
if [[ -z $proto || -z $port ]]; then
    echo "can't get proto or port from $server_conf"
    exit 1
fi
echo "ca_name=$ca_name, server_name=$server_name, name=$name, ip=$ip, proto=$proto, port=$port"

mkdir -p "$CLIENT_DIR"

cd $CA_DIR/easy-rsa
# ca related
if [[ -f keys/ca.crt ]]; then
    ln -s $CA_DIR/easy-rsa/keys/ca.crt $CLIENT_DIR/ca.crt
else
    echo "error, no ca.crt"
    exit 1
fi

if [[ -f keys/ta.key ]]; then
    ln -s $CA_DIR/easy-rsa/keys/ta.key $CLIENT_DIR/ta.key
else
    echo "error, no ta.key"
    exit 1
fi
# client crt/key
source vars && ./pkitool $name

if [[ -f keys/${name}.crt ]]; then
    ln -s $CA_DIR/easy-rsa/keys/$name.crt $CLIENT_DIR/$name.crt
else
    echo "error, no ${name}.crt"
    exit 1
fi

if [[ -f keys/${name}.key ]]; then
    ln -s $CA_DIR/easy-rsa/keys/$name.key $CLIENT_DIR/$name.key
else
    echo "error, no ${name}.key"
    exit 1
fi
# conf
command cp -f $TPL_DIR/client.tpl $CLIENT_DIR/$name.ovpn
sed -i "s/__NAME__/$name/" $CLIENT_DIR/$name.ovpn
sed -i "s/__PROTO__/$proto/" $CLIENT_DIR/$name.ovpn
sed -i "s/__IP__/$ip/" $CLIENT_DIR/$name.ovpn
sed -i "s/__PORT__/$port/" $CLIENT_DIR/$name.ovpn

echo "client conf generated in dir $CLIENT_DIR"

cd $CLIENTS_DIR
zip -r $name.zip $name/*
echo "zipped file is $CLIENT_DIR.zip"

exit 0
