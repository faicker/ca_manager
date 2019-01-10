port __PORT__
proto __PROTO__
dev tun
topology subnet
ca ca.crt
cert __SERVER_NAME__.crt
key __SERVER_NAME__.key
dh dh.pem
server 10.255.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
#push "route 10.4.0.0 255.255.0.0"
client-config-dir ccd
duplicate-cn
keepalive 10 60
tls-auth ta.key 0
comp-lzo
persist-key
persist-tun
status /var/log/openvpn_status___SERVER_NAME__.log
log-append /var/log/openvpn___SERVER_NAME__.log
