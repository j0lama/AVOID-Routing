#/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: $0 "
fi

sudo apt update -y
sudo apt install -y wireguard

if [ $1 = "gw" ]; then
    git clone https://j0lama:$2@github.com/j0lama/avoid_gw.git
    cd avoid_gw/
    ./initialize.sh
elif [ $1 = "home_gw" ]; then
    git clone https://j0lama:$2@github.com/j0lama/avoid_home_gw.git
    cd avoid_home_gw/
    ./initialize.sh
else
  echo "Invalid option"
  exit 1
fi
