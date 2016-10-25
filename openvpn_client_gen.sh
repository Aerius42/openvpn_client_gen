#!/bin/bash
#
# Script Name: openvpn_client_gen.sh
#
# Author: Charles Nguyen <nguyencharles42@gmail.com>
# Date : 02/10/2016
# Description: OpenVPN key and conf generator
#


default_port=443

function valid_id
{
	[[ -n $1 && $1 =~ ^[a-zA-Z0-9]+$ ]]
	return $?
}

function valid_ip
{
	local ip=$1
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		return $?
        fi
	return 1
}

function valid_port
{
	[[ $1 =~ ^[0-9]{1,6}$ && $1 -le 65535 ]]
	return $?
}

echo "Make sure you have the administrator right"

valid_token=false
until $valid_token; do
	read -p "Unique client id: " id
	if valid_id $id; then
		valid_token=true
	else
		echo "Error: invalid name"
	fi
done

default_ip=`/sbin/ifconfig eth0 | grep 'inet adr:' | cut -d: -f2 | awk '{print $1}'`
valid_token=false
until $valid_token; do
	read -p "Destination IP [default: $default_ip] ? " ip
	if [ -z $ip ]; then
		ip=$default_ip
	fi
	if valid_ip $ip; then
		valid_token=true
	else
		echo "Error: Bad IP"
	fi
done

valid_token=false
until $valid_token; do
	read -p "Choose your port [default: $default_port]: " port
	if [ -z $port ]; then
		port=$default_port
	fi
	if valid_port $port; then
		valid_token=true
	else
		echo "Error: Bad port"
	fi
done

cd /etc/openvpn/easy-rsa
source vars
./build-key $id
if [ $? -eq 0 ]; then
	mkdir -p /etc/openvpn/clientconf/$id/
	cp /etc/openvpn/ca.crt /etc/openvpn/ta.key keys/$id.* /etc/openvpn/clientconf/$id/
	cd /etc/openvpn/clientconf/$id/
	chmod 644 *

	cat > client.conf <<- EOF
# Client
client
dev tun
proto tcp-client
remote $ip $port
resolv-retry infinite
cipher AES-256-CBC
 
# Keys
ca ca.crt
cert $id.crt
key $id.key
tls-auth ta.key 1
 
# Security
nobind
persist-key
persist-tun
comp-lzo
verb 3
	EOF

	echo "-----"
	echo "Finished ! You will find the new key named $id here:"
	echo "/etc/openvpn/clientconf/$id/"
else
	echo "-----"
	echo "Error: Have you checked you have the administor rights ?"
fi

