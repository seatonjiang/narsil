#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_dnsserver()
{
    msg_info '\n%s\n' "[${STATS}] 配置 DNS 服务器"

    VERIFY=${VERIFY:-'Y'}
    METADATA=${METADATA:-'Y'}
    DNS_SERVER=${DNS_SERVER:-'119.29.29.29 223.5.5.5'}

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            DNS_SERVER='183.60.83.19 183.60.82.98'
        fi
    fi

    if [ -f /etc/cloud/cloud.cfg ]; then
        sed -i '/resolv_conf/d' /etc/cloud/cloud.cfg
    fi

    systemctl stop systemd-resolved.service >/dev/null 2>&1
    systemctl disable systemd-resolved.service >/dev/null 2>&1
    systemctl mask systemd-resolved.service >/dev/null 2>&1

    find /etc/resolv.conf -delete

    for NAMESERVER in ${DNS_SERVER}; do
        echo "nameserver ${NAMESERVER}" >> /etc/resolv.conf
    done

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 配置文件（/etc/systemd/resolved.conf）"
        grep -Ev '^#|^$' /etc/resolv.conf | uniq
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
