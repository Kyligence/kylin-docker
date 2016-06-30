#!/bin/bash
service sshd start

$KYLIN_HOME/bin/kylin.sh start

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
