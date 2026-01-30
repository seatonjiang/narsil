#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_tcpbbr()
{
    msg_info '\n%s\n' "[${STATS}] 配置 TCP BBR 拥塞控制算法"

    VERIFY=${VERIFY:-'Y'}

    if ! sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr; then
        {
            echo -e '\n# 配置 TCP BBR 拥塞控制算法'
            echo "net.core.default_qdisc=fq"
            echo "net.ipv4.tcp_congestion_control=bbr"
        } >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1
    fi

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 内核参数"
        sysctl net.ipv4.tcp_available_congestion_control
        msg_notic '\n%s\n' "• 内核模块"
        lsmod | grep bbr
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
