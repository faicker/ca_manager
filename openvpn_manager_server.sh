#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`
TPL_DIR="`pwd`/ca_manager/openvpn_template"
OPENVPN_DIR="`pwd`/ca_manager/openvpn"

ca_name=$1
server_name=$2
proto=$3
port=$4

if [[ -z "$server_name" || $# -lt 2 ]]; then
    echo "usage: $0 ca_name server_name proto port"
    exit 1
else
    if [[ -d $OPENVPN_DIR/$ca_name/$server_name ]]; then
        #rm -rf $OPENVPN_DIR/$ca_name/$server_name
        echo "server $server_name is already exist."
        exit 2
    fi
    [[ -z $proto ]] && proto="udp"
    [[ -z $port ]] && port="1194"
fi

echo "ca_name=$ca_name, server_name=$server_name, proto=$proto, port=$port"

CA_DIR="$OPENVPN_DIR/$ca_name"
if [[ ! -d $CA_DIR ]]; then
   echo "no dir $CA_DIR" 
   exit 2
fi

SERVER_DIR="$CA_DIR/$server_name"

mkdir -p $SERVER_DIR/$server_name
# ca related
cd $CA_DIR/easy-rsa
if [[ ! -f keys/dh1024.pem ]]; then
    echo "error, no dh1024.pem"
    exit 1
else
    ln -s $CA_DIR/easy-rsa/keys/dh1024.pem $SERVER_DIR/$server_name/dh1024.pem
fi

if [[ ! -f keys/ca.crt ]]; then
    echo "error, no ca.crt"
    exit 1
else
    ln -s $CA_DIR/easy-rsa/keys/ca.crt $SERVER_DIR/$server_name/ca.crt 
fi

if [[ ! -f keys/ta.key ]]; then
    echo "error, no ta.key"
    exit 1
else
    ln -s $CA_DIR/easy-rsa/keys/ta.key $SERVER_DIR/$server_name/ta.key 
fi

# want: server.key, server.crt
source ./vars && ./pkitool --server $server_name
if [[ ! -f keys/$server_name.key ]]; then
    echo "error, server.key"
    exit 1
fi
ln -s $CA_DIR/easy-rsa/keys/$server_name.crt $SERVER_DIR/$server_name/$server_name.crt
ln -s $CA_DIR/easy-rsa/keys/$server_name.key $SERVER_DIR/$server_name/$server_name.key
# conf
command cp -f $TPL_DIR/server.tpl $SERVER_DIR/$server_name/$server_name.conf
sed -i "s/__SERVER_NAME__/$server_name/" $SERVER_DIR/$server_name/$server_name.conf
sed -i "s/__PROTO__/$proto/" $SERVER_DIR/$server_name/$server_name.conf
sed -i "s/__PORT__/$port/" $SERVER_DIR/$server_name/$server_name.conf
mkdir $SERVER_DIR/$server_name/ccd

cd $SERVER_DIR/
zip -r $server_name.zip $server_name/*
#rm -rf $server_name
exit 0
