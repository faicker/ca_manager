#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`
TPL_DIR="`pwd`/ca_manager/openvpn_template"
OPENVPN_DIR="`pwd`/ca_manager/openvpn"

ca_name=$1
server_name=$2
name=$3
ip=$4
proto=$5
port=$6

if [[ $# -lt 4 ]]; then
    echo "usage: $0 ca_name server_name client_name server_ip proto server_port"
    exit 1
else
    [[ -z $proto ]] && proto="udp"
    [[ -z $port ]] && port="1194"
fi

CA_DIR="$OPENVPN_DIR/$ca_name"
SERVER_DIR="$CA_DIR/$server_name"
if [[ ! -d $SERVER_DIR ]]; then
    echo "error, generate server first"
    exit 1
else
    mkdir -p $SERVER_DIR/client-configs/$name
fi

cd $CA_DIR/easy-rsa
# ca related
if [[ -f keys/ca.crt ]]; then
    ln -s $CA_DIR/easy-rsa/keys/ca.crt $SERVER_DIR/client-configs/$name/ca.crt 
else
    echo "error, no ca.crt"
    exit 1
fi

if [[ -f keys/ta.key ]]; then
    ln -s $CA_DIR/easy-rsa/keys/ta.key $SERVER_DIR/client-configs/$name/ta.key 
else
    echo "error, no ta.key"
    exit 1
fi
# client crt/key
source vars && ./pkitool $name

if [[ -f keys/${name}.crt ]]; then
    ln -s $CA_DIR/easy-rsa/keys/$name.crt $SERVER_DIR/client-configs/$name/$name.crt 
else
    echo "error, no ${name}.crt"
    exit 1
fi

if [[ -f keys/${name}.key ]]; then
    ln -s $CA_DIR/easy-rsa/keys/$name.key $SERVER_DIR/client-configs/$name/$name.key 
else
    echo "error, no ${name}.key"
    exit 1
fi
# conf
command cp -f $TPL_DIR/client.tpl $SERVER_DIR/client-configs/$name/$name.ovpn
sed -i "s/__NAME__/$name/" $SERVER_DIR/client-configs/$name/$name.ovpn
sed -i "s/__PROTO__/$proto/" $SERVER_DIR/client-configs/$name/$name.ovpn
sed -i "s/__IP__/$ip/" $SERVER_DIR/client-configs/$name/$name.ovpn
sed -i "s/__PORT__/$port/" $SERVER_DIR/client-configs/$name/$name.ovpn

cd $SERVER_DIR/client-configs
zip -r $name.zip $name/*
#rm -rf $name
exit 0
