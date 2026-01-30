#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_timezone()
{
    msg_info '\n%s\n' "[${STATS}] 配置系统时区"

    VERIFY=${VERIFY:-'Y'}
    TIME_ZONE=${TIME_ZONE:-'Asia/Shanghai'}

    timedatectl set-timezone "${TIME_ZONE}"
    timedatectl set-local-rtc 0

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 时区配置"
        ls -la /etc/localtime
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
