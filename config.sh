#!/bin/bash
source bin/activate
pip install -r requirements.txt
# Find which interface connects us to the server
prefix=$(cat /etc/hosts | grep server |  cut -f1-3 -d".")
iface=$(route -n  | grep "$prefix" | awk '{print $8}')
# Write it in the first line of configuration file
echo $iface > configuration.txt
# Find the IP address of other hosts and add them to the configuration file
address=$(cat /etc/hosts | grep client | awk '{print $1}')
echo "client $address" >> configuration.txt

for i in `seq 1 12`;
do
  address=$(cat /etc/hosts | grep "a$i$" | awk '{print $1}')
  echo "a$i $address" >> configuration.txt
done
