#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_hostname()
{
    HOSTNAME=${HOSTNAME:-'Narsil'}
    METADATA=${METADATA:-'Y'}

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            HOSTNAME=$(wget -qO- -t1 -T2 metadata.tencentyun.com/latest/meta-data/instance-name)
        fi
    fi

    if [ "${HOSTNAME}" == "未命名" ]; then
        HOSTNAME='Narsil'
    fi

    msg_notic '\n%s' "请输入新的主机名（默认 ${HOSTNAME}）："

    while :; do
        read -r GET_HOSTNAME
        NEW_HOSTNAME=${GET_HOSTNAME:-"${HOSTNAME}"}
        break
    done

    OLD_HOSTNAME=$(hostname)

    hostnamectl set-hostname --static "${NEW_HOSTNAME}"
    sed -i "s@${OLD_HOSTNAME}@${NEW_HOSTNAME}@g" /etc/hosts

    if [ -f /etc/cloud/cloud.cfg ]; then
        sed -i '/update_hostname/d' /etc/cloud/cloud.cfg
    fi

    msg_succ '\n%s\n\n' "主机名修改成功！"

    exit 0
}
