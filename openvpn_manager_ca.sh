#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`
TPL_DIR="`pwd`/ca_manager/openvpn_template"
OPENVPN_DIR="`pwd`/ca_manager/openvpn"

ca_name=$1

if [[ -z "$ca_name" ]]; then
    ca_name="default"
fi
if [[ -d $OPENVPN_DIR/$ca_name ]]; then
    echo "ca $ca_name already exist"
    exit 1
fi

echo "name=$ca_name"

CA_DIR="$OPENVPN_DIR/$ca_name"

mkdir -p $CA_DIR
cp -r easy-rsa $CA_DIR/easy-rsa
chmod -R 755 $CA_DIR/easy-rsa
ln -s $CA_DIR/easy-rsa/openssl-1.0.0.cnf $CA_DIR/easy-rsa/openssl.cnf

\cp -f $TPL_DIR/vars.tpl $CA_DIR/easy-rsa/vars
#sed -i "s/__NAME__/$ca_name/" $CA_DIR/easy-rsa/vars

cd $CA_DIR/easy-rsa

# want: dh1024.pem
source ./vars && ./clean-all && ./build-dh
if [[ ! -f keys/dh1024.pem ]]; then
    echo "error dh1024.pem"
    exit 1
fi

# want: ca.key, ca.crt
source ./vars && ./pkitool --initca
if [[ ! -f keys/ca.key || ! -f keys/ca.crt ]]; then
    echo "error ca.key/ca.crt"
    exit 1
fi

# want ta.key
openvpn --genkey --secret keys/ta.key
if [[ ! -f keys/ta.key ]]; then
    echo "error, ta.key"
    exit 1
fi

exit 0
