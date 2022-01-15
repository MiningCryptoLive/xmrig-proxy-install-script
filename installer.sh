#!/bin/bash

echo "CHECKING FOR PREVIOUS INSTALL..."
echo
FILE=xmrig-proxy/build/xmrig-proxy
if test -f "$FILE"; then
    echo "$FILE exists.... ABORTING INSTALLATION"
    exit 1
fi


echo
# Upgrade OS
echo "Checking for system updates"; sudo apt update &> /dev/null
echo
echo "Installing updates"; sudo apt upgrade -y &> /dev/null
echo
echo "Installing required packages"; sudo apt install -y git build-essential cmake libuv1-dev uuid-dev libmicrohttpd-dev libssl-dev &> /dev/null
echo

echo CLONING FROM GIT
echo

# Clone and build xmrig-proxy lastest src code
cd ~
git clone https://github.com/xmrig/xmrig-proxy.git

reset

echo
echo
echo "STARTING BUILD"
echo
echo

# build xmrig-proxy default
mkdir xmrig-proxy/build

cd xmrig-proxy/build

cmake ..

make -j$(nproc)

# Allow binary execution
sudo chmod +x xmrig-proxy

reset

echo "BUILD FINISHED!"
echo
echo


# Gather variables for config file
echo "Enter Wallet Address:"
read YOUR_WALLET_ADDRESS

echo
echo

echo "Enter device display name/Pool Password:"
read YOUR_RIG_NAME




cat > config.json << EOF
{
"bind": [

{

"host": "0.0.0.0",

"port": 3333,

"tls": false

},

{

"host": "::",

"port": 3333,

"tls": false

} ],

"pools": [

{

"algo": null,

"coin": null,

"url": "mine.monerod.org:4444",

"user": "$YOUR_WALLET_ADDRESS",

"pass": "$YOUR_RIG_NAME",

"rig-id": null,

"nicehash": false,

"keepalive": true,

"enabled": true,

"tls": true,

"tls-fingerprint": null,

"daemon": false,

"socks5": null,

"self-select": null,

"submit-to-origin": false

}]}
EOF

echo
echo
# UFW
echo "Adding firewall rules"
echo
sudo ufw allow 3333 &> /dev/null
sudo ufw allow 22 &> /dev/null
sudo ufw enable


# Create cron job
#write out current crontab
sudo crontab -l > mycron
#echo new cron into cron file
echo "@reboot sudo screen -dmS xmrig-proxy-screen /root/xmrig-proxy/build/xmrig-proxy" >> mycron
#install new cron file
sudo crontab mycron
sudo rm mycron
echo
echo
echo "Rebooting...!"
echo
echo
sudo reboot
