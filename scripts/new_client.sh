#!/bin/bash

MACHINE_NAME=$(hostname -s)
GW_INDEX=${MACHINE_NAME#"gateway"}
CLIENT_INDEX=$(cat /local/repository/config/avoid.conf | grep "[Peer]" | wc -l)
CLIENT_INDEX=$((CLIENT_INDEX + 2))
CLIENT_IP="1.0.$GW_INDEX.$CLIENT_INDEX"
INTERNET_IFACE=$(route | grep '^default' | grep -o '[^ ]*$')
GW_IP=$(ifconfig $INTERNET_IFACE | grep 'inet ' | awk '{ print $2}')
GW_PUB_KEY=$(cat /local/repository/config/gw_pub)
PRIV_KEY=$(wg genkey)

cp /local/repository/config/client.conf /tmp/client.conf

sed -i "s%\PRIV_KEY%$PRIV_KEY%g" /tmp/client.conf
sed -i "s/CLIENT_IP/$CLIENT_IP/g" /tmp/client.conf
sed -i "s%\GW_PUB_KEY%$GW_PUB_KEY%g" /tmp/client.conf
sed -i "s/GW_IP/$GW_IP/g" /tmp/client.conf

# Generate QR from temporary client config file
cat /tmp/client.conf | qrencode -t ansiutf8 

# Add Peer entry to GW config file
#[Peer]
#PublicKey = <contents-of-client-publickey>
#AllowedIPs = 10.0.0.2/32