client
ca ca.crt
cert __NAME__.crt
key __NAME__.key
tls-auth ta.key 1
dev tun
proto __PROTO__
remote __IP__ __PORT__
resolv-retry 3
nobind
persist-key
persist-tun
verb 3
auth-user-pass
remote-cert-tls server
auth-nocache
