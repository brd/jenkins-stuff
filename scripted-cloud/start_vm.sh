#!/bin/sh -x

DATE=`date +%Y%m%d-%H:%M:%S`

env

echo "${DATE} start VM.. ${UPSTREAM}"

if [ -z "${SLAVE_NAME}" ]; then
    echo "SLAVE_NAME not defined"
    exit 10
fi

if [ ! -d /usr/local/vm/${SLAVE_NAME} ]; then
    sudo vm create ${SLAVE_NAME}
else
    ps -ax | grep "bhyve: ${SLAVE_NAME}" | grep -v grep > /dev/null
    if [ $? -eq 0 ]; then
        echo "bhyve already running"
        exit 15
    fi
fi

# Override VM specs
sudo sysrc -f /usr/local/vm/${SLAVE_NAME}/${SLAVE_NAME}.conf memory=1G network0_switch="local"

UPSTREAM=$( echo ${SLAVE_NAME} | sed -e 's/bhyve-//' )
SUCCESSFUL=$( grep lastSuccessfulBuild /usr/local/jenkins/jobs/${UPSTREAM}*build/builds/permalinks | awk '{print $2}')

sudo cp /usr/local/jenkins/jobs/${UPSTREAM}*build/builds/${SUCCESSFUL}/archive/poudriereimage-gpt.img.xz /usr/local/vm/${SLAVE_NAME}/disk0.img.xz
[ -f /usr/local/vm/${SLAVE_NAME}/disk0.img ] && sudo rm /usr/local/vm/${SLAVE_NAME}/disk0.img
sudo unxz /usr/local/vm/${SLAVE_NAME}/disk0.img.xz

sudo vm start ${SLAVE_NAME}

RES=0
while [ ${RES} -lt 60 ]; do
    nc -w 2 -z bhyve-13-stable 22
    if [ $? -eq 0 ]; then
        RES=100
        exit 0
    else
        RES=$(( ${RES} + 1 ))
        sleep 1
    fi
done
exit 20
