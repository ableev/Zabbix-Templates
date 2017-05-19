#!/bin/bash

ZABBIX_SERVER=$1
if [ -z "${ZABBIX_SERVER}" ]
then
    echo "Zabbix server is not provided, exiting..."
    exit 1
fi

HOSTNAME="$(hostname -f)"

CURL="$(which curl) --connect-timeout 5 --max-time 10 -s"
ZABBIX_SENDER="$(which zabbix_sender) --zabbix ${ZABBIX_SERVER} --port 10051 -i -"

URL_STATUS="http://localhost/nginx-status"

STATUS="$(${CURL} ${URL_STATUS})"

nginx_active=$(echo "${STATUS}" | grep -E 'Active connections:' | grep -Eo '[0-9]+')
nginx_reading=$(echo "${STATUS}" | grep -Eo 'Reading:\ [0-9]+' | grep -Eo '[0-9]+')
nginx_writing=$(echo "${STATUS}" | grep -Eo 'Writing:\ [0-9]+' | grep -Eo '[0-9]+')
nginx_waiting=$(echo "${STATUS}" | grep -Eo 'Waiting:\ [0-9]+' | grep -Eo '[0-9]+')
nginx_accepted=$(echo "${STATUS}" | sed -n '3p'|cut -d' ' -f2)
nginx_handled=$(echo "${STATUS}" | sed -n '3p'|cut -d' ' -f3)
nginx_requests=$(echo "${STATUS}" | sed -n '3p'|cut -d' ' -f4)

echo_status () {
    echo "${HOSTNAME} nginx.active $nginx_active"
    echo "${HOSTNAME} nginx.reading $nginx_reading"
    echo "${HOSTNAME} nginx.writing $nginx_writing"
    echo "${HOSTNAME} nginx.waiting $nginx_waiting"
    echo "${HOSTNAME} nginx.accepted $nginx_accepted"
    echo "${HOSTNAME} nginx.handled $nginx_handled"
    echo "${HOSTNAME} nginx.requests $nginx_requests"
}

echo_status | ${ZABBIX_SENDER}
touch /tmp/nginx.status.ts
