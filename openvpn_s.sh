#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`
. common.def

ca_name=$1
server_name=$2
proto=$3
port=$4

if [[ -z "$server_name" || $# -lt 2 ]]; then
    echo "usage: $0 ca_name server_name proto port"
    exit 1
else
    [[ -z $proto ]] && proto="udp"
    [[ -z $port ]] && port="1194"
fi

echo "ca_name=$ca_name, server_name=$server_name, proto=$proto, port=$port"

CA_DIR="$OPENVPN_DIR/$ca_name"
SERVERS_DIR="$CA_DIR/servers"
SERVER_DIR="$SERVERS_DIR/$server_name"
if [[ ! -d $CA_DIR ]]; then
   echo "no dir $CA_DIR"
   exit 1
elif [[ -d $SERVER_DIR ]]; then
    echo "server $server_name exist"
    exit 1
fi
mkdir -p $SERVER_DIR

# ca related
cd $CA_DIR/easy-rsa
if [[ ! -f keys/dh.pem ]]; then
    echo "error, no dh.pem"
    exit 1
else
    ln -s $CA_DIR/easy-rsa/keys/dh.pem $SERVER_DIR/dh.pem
fi

if [[ ! -f keys/ca.crt ]]; then
    echo "error, no ca.crt"
    exit 1
else
    ln -s $CA_DIR/easy-rsa/keys/ca.crt $SERVER_DIR/ca.crt
fi

if [[ ! -f keys/ta.key ]]; then
    echo "error, no ta.key"
    exit 1
else
    ln -s $CA_DIR/easy-rsa/keys/ta.key $SERVER_DIR/ta.key
fi

# want: server.key, server.crt
source ./vars && ./pkitool --server $server_name
if [[ ! -f keys/$server_name.key ]]; then
    echo "error, server.key"
    exit 1
fi
ln -s $CA_DIR/easy-rsa/keys/$server_name.crt $SERVER_DIR/$server_name.crt
ln -s $CA_DIR/easy-rsa/keys/$server_name.key $SERVER_DIR/$server_name.key
# conf
command cp -f $TPL_DIR/server.tpl $SERVER_DIR/$server_name.conf
sed -i "s/__SERVER_NAME__/$server_name/" $SERVER_DIR/$server_name.conf
sed -i "s/__PROTO__/$proto/" $SERVER_DIR/$server_name.conf
sed -i "s/__PORT__/$port/" $SERVER_DIR/$server_name.conf
mkdir $SERVER_DIR/ccd

echo "server conf generated in dir $SERVER_DIR"

cd $SERVERS_DIR/
zip -r $server_name.zip $server_name/*
echo "zipped file is $SERVER_DIR.zip"

exit 0
