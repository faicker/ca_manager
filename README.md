# CAManager
Simple bash scripts to generate ca/cert/key for openvpn or other.

##openvpn_manager_ca.sh
copy easy_rsa directory and init ca crt/key, like ca.key, ca.crt, dh1024.pem, ta.key. The directory is ca_manager/openvpn/$ca_name/
```
openvpn_manager_ca.sh [ca_name=default]
```

##openvpn_manager_server.sh
Generate server cert and key based on ca `ca_name`, server openvpn conf is also generated. The directory is ca_manager/openvpn/$ca_name/$server_name
```
openvpn_manager_server.sh ca_name server_name proto port
```

##openvpn_manager_client.sh
Generate client cert and key based on ca `ca_name` and sever `server_name`, client openvpn conf is also generated. The directory is ca_manager/openvpn/$ca_name/$server_name/$client_name
```
openvpn_manager_client.sh ca_name server_name client_name server_ip proto server_port
```
##revoke.sh
revoke cert.
```
revoke.sh common_name
```
##Notes:
1. depend on openssl
2. The client/server cert/key generated base on the same CA, can be mixed.
