#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_removepackages()
{
    msg_info '\n%s\n' "[${STATS}] 移除无用软件包"

    REMOVE_PACKAGE="open-vm-tools popularity-contest"

    for PACKAGE in ${REMOVE_PACKAGE}; do
        apt-get purge "${PACKAGE}" -y >/dev/null 2>&1
    done

    msg_succ '%s\n' "操作完成！"

    sleep 1

    ((STATS++))
}
