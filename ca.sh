#!/bin/bash

cd `dirname ${BASH_SOURCE[0]}`
. common.def

ca_name=$1

if [[ -z $ca_name ]]; then
    echo "usage: $0 ca_name"
    exit 1
fi

echo "name=$ca_name"

CA_DIR=$OPENVPN_DIR/$ca_name
if [[ -d $CA_DIR ]]; then
    echo "ca $ca_name already exist"
    exit 1
fi

mkdir -p $CA_DIR
cp -r easy-rsa $CA_DIR/easy-rsa
chmod -R 755 $CA_DIR/easy-rsa
ln -s $CA_DIR/easy-rsa/openssl-1.0.0.cnf $CA_DIR/easy-rsa/openssl.cnf

command cp -f $TPL_DIR/vars.tpl $CA_DIR/easy-rsa/vars

cd $CA_DIR/easy-rsa

# want: dh.pem
source ./vars && ./clean-all && ./build-dh
if [[ ! -f keys/dh$KEY_SIZE.pem ]]; then
    echo "error dh$KEY_SIZE.pem"
    exit 1
fi
mv keys/dh$KEY_SIZE.pem keys/dh.pem

# want: ca.key, ca.crt
source ./vars && ./pkitool --initca
if [[ ! -f keys/ca.key || ! -f keys/ca.crt ]]; then
    echo "error ca.key/ca.crt"
    exit 1
fi

# want ta.key
if ! which openvpn >/dev/null; then
    echo "ta.key not generated"
else
    openvpn --genkey --secret keys/ta.key
    if [[ ! -f keys/ta.key ]]; then
        echo "error, ta.key"
        exit 1
    fi
fi

echo "key generated in dir $CA_DIR/easy-rsa/keys"
exit 0
