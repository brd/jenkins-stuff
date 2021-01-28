#!/bin/sh

env

echo "stop VM.."

ps -ax | grep "bhyve: ${SLAVE_NAME}" | grep -v grep > /dev/null
if [ $? -eq 0 ]; then
   sudo vm poweroff -f ${SLAVE_NAME}
fi

sleep 5

if [ -d /usr/local/vm/${SLAVE_NAME} ]; then
   sudo vm destroy -f ${SLAVE_NAME}
fi
