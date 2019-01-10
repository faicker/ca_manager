#!/usr/bin/env bash


cd `dirname ${BASH_SOURCE[0]}`
. common.def

if [[ $# -lt 2 ]]; then
    echo "usage: $0 ca_name common_name"
    exit 1
fi

ca_name=$1
common_name=$2

CA_DIR="$OPENVPN_DIR/$ca_name"
if [[ ! -d $CA_DIR ]]; then
   echo "no dir $CA_DIR"
   exit 1
fi

cd $CA_DIR/easy-rsa
source ./vars
./revoke-full $common_name
echo "crl is $CA_DIR/easy-rsa/keys/crl.pem"
echo "rename $common_name to revoked"
mv $CA_DIR/easy-rsa/keys/$common_name.crt{,.revoked}
mv $CA_DIR/easy-rsa/keys/$common_name.key{,.revoked}
mv $CA_DIR/easy-rsa/keys/$common_name.csr{,.revoked}
mv $CA_DIR/$common_name $CA_DIR/$common_name.revoked
