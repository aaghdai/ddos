#!/bin/bash
source bin/activate
pip install -r requirements.txt
# Find the IP address of other hosts and add them to the configuration file
address=$(cat /etc/hosts | grep client | awk '{print $1}')
echo "client $address" > GENI/addresses.txt

for i in `seq 1 12`;
do
  address=$(cat /etc/hosts | grep "a$i$" | awk '{print $1}')
  echo "a$i $address" >> GENI/addresses.txt
done
