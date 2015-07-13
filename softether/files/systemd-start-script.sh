#!/bin/bash
# This file is managed by salt, do not edit.
[ -f /etc/default/softether-vpnclient ] && source /etc/default/softether-vpnclient

/opt/vpnclient/vpnclient start
PID=$?
sleep 2
ifup $IFUP_INTERFACE
exit 0
