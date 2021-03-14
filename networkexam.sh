#!/bin/sh

nmcli con show | grep "System eth2" && nmcli con mod "System eth2" connection.id ansible
nmcli con show | grep "System eth0" && nmcli con mod "System eth0" connection.id internal
nmcli device status | grep "external" || nmcli con delete $( nmcli --fields UUID,DEVICE con show | grep eth1 | awk '{ print $1}' )
