#/bin/bash

# Redirect output to log file
exec >> /local/repository/deploy.log
exec 2>&1

if [ "$#" -ne 1 ]; then
    echo "USAGE: $0 <gw/home_gw>"
    exit 1
fi

sudo apt update -y
sudo apt install -y wireguard qrencode

if [ $1 = "gw" ]; then
    INTERNET_IFACE=$(route | grep '^default' | grep -o '[^ ]*$')
    MACHINE_NAME=$(hostname -s)
    GW_INDEX=${MACHINE_NAME#"gateway"}
    # Generate Gateway keys
    if [ ! -f /local/repository/config/gw_priv ]; then # If private key does not exist
        wg genkey | tee /local/repository/config/gw_priv
    fi
    if [ ! -f /local/repository/config/gw_pub ]; then # If public key does not exist
        cat /local/repository/config/gw_priv | wg pubkey > /local/repository/config/gw_pub
    fi
    PRIV_KEY=$(cat /local/repository/config/gw_priv)
    # Generate config file
    sed -i "s%\PRIV_KEY%$PRIV_KEY%g" /local/repository/config/avoid.conf
    sed -i "s/GW_INDEX/$GW_INDEX/g" /local/repository/config/avoid.conf
    sed -i "s/INTERNET_IFACE/$INTERNET_IFACE/g" /local/repository/config/avoid.conf
    # Start VPN
    sudo wg-quick up /local/repository/config/avoid.conf
elif [ $1 = "home_gw" ]; then
    :
else
  echo "Invalid option"
  exit 1
fi
