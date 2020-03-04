# ca_manager

Simple bash scripts to generate ca/cert/key for openvpn or other.

## ca.sh
copy easy_rsa directory and init ca crt/key, like ca.key, ca.crt, dh.pem, ta.key.

The directory is ca_manager/openvpn/$ca_name.

```
./ca.sh ca_name
```

## openvpn_s.sh
Generate server cert and key based on ca `ca_name`, server openvpn conf is also generated.

The directory is ca_manager/openvpn/$ca_name/servers/$server_name.

```
./openvpn_s.sh ca_name server_name proto port
```

## openvpn_c.sh
Generate client cert and key based on ca `ca_name` and sever `server_name`, client openvpn conf is also generated.

The directory is ca_manager/openvpn/$ca_name/servers/$server_name/client-configs/$client_name.

```
./openvpn_c.sh ca_name server_name client_name server_ip
```

## revoke.sh

revoke cert.

```
revoke.sh ca_name common_name
```

## Notes:
1. depend on openssl, openvpn and zip
2. The client/server cert/key generated base on the same CA, can be mixed.
