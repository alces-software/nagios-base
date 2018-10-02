#!/bin/bash

if [ "$1" == "-q" ] ; then
   quiet=1
else
   quiet=0
fi

for i in a1 a2 a3 a4 b1 b2
do
  for j in 1 2
  do
    if [ $quiet -eq 1 ] ; then
      /root/pdus/getpduload.sh ${i}pdu${j} >> /tmp/pduout.$$ 2>&1
    else
      /root/pdus/getpduload.sh ${i}pdu${j} | tee -a /tmp/pduout.$$
    fi
  done
done

total=0
for pdu in `grep PDU /tmp/pduout.$$ | awk '{print $5}'`
do
   total=`expr $total + $pdu`
done

totp1=0
for pdu in `grep PDU /tmp/pduout.$$ | awk '{print $16}' | sed 's?[A,(,)]??g'`
do
   totp1=`expr $totp1 + $pdu`
done

totp2=0
for pdu in `grep PDU /tmp/pduout.$$ | awk '{print $18}' | sed 's?[A,(,)]??g'`
do
   totp2=`expr $totp2 + $pdu`
done

totp3=0
for pdu in `grep PDU /tmp/pduout.$$ | awk '{print $20}' | sed 's?[A,(,)]??g'`
do
   totp3=`expr $totp3 + $pdu`
done

if [ $quiet -eq 0 ] ; then
  echo
fi

now=`date`
echo "$now: Total of $total W across all PDUs (${totp1}A Ph1, ${totp2}A Ph2, ${totp3}A Ph3)"

rm -f /tmp/pduout.$$
