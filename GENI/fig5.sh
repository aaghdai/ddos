#!/bin/bash
AtkStart=1.5
BinLen=600

prefix=$(cat /etc/hosts | grep server |  cut -f1-3 -d".")
iface=$(route -n  | grep "$prefix" | awk '{print $8}')
TestDur=$1
of=$2

AtkDuration=$(expr $TestDur - $AtkStart)

if [ ! -f "addresses.txt" ]
then
    echo 'Please run config before starting the experiment'
    exit
fi

sudo ./capture_and_analyze.py $iface $TestDur --output $of --bin $BinLen --show > ${of}point.txt &

ssh -o "StrictHostKeyChecking no" client "nohup ITGSend -a server -l sender.log -x receiver.log -C 25 -c 500 -T UDP -t ${TestDur}000 > client.log &"

sleep $AtkStart

for a in a1 a2 a3 a4 a5 a6
do
    ssh -o "StrictHostKeyChecking no" $a "nohup ITGSend -a server -l sender.log -x receiver.log -C 125 -c 500 -T UDP -t ${AtkDuration}000 > $a.log &"
done

for a in a7 a8 a9 a10 a11 a12
do
    ssh -o "StrictHostKeyChecking no" $a "nohup ITGSend -a server -l sender.log -x receiver.log -C 250 -c 500 -T UDP -t ${AtkDuration}000 > $a.log &"
done

wait
sudo chmod 744 ${of}*png

sleep 10

for i in 100 125 150 175 200 
do
    AVG=""
    for j in 1 2 3 4 5
    do
        sudo ./capture_and_analyze.py $iface $TestDur --output $of --bin $BinLen > fig5.tmp &

        ssh -o "StrictHostKeyChecking no" client "nohup ITGSend -a server -l sender.log -x receiver.log -C 25 -c 500 -T UDP -t ${TestDur}000 > client.log &"

        sleep $AtkStart

        for a in a1 a2 a3 a4 a5 a6
        do
            ssh -o "StrictHostKeyChecking no" $a "nohup ITGSend -a server -l sender.log -x receiver.log -C $i -c 500 -T UDP -t ${AtkDuration}000 > $a.log &"
        done

        for a in a7 a8 a9 a10 a11 a12
        do
            ssh -o "StrictHostKeyChecking no" $a "nohup ITGSend -a server -l sender.log -x receiver.log -C 250 -c 500 -T UDP -t ${AtkDuration}000 > $a.log &"
done

        wait
        AVG="$AVG $(<fig5.tmp)"
        sleep 10
    done
    echo "$i: $AVG"
done
