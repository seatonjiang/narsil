#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_ntpserver()
{
    msg_info '\n%s\n' "[${STATS}] 配置 NTP 服务器"

    VERIFY=${VERIFY:-'Y'}
    METADATA=${METADATA:-'Y'}
    NTP_SERVER=${NTP_SERVER:-'ntp1.tencent.com ntp2.tencent.com ntp3.tencent.com ntp4.tencent.com ntp5.tencent.com'}

    systemctl stop systemd-timesyncd >/dev/null 2>&1
    systemctl mask systemd-timesyncd >/dev/null 2>&1

    apt-get purge ntp -y >/dev/null 2>&1

    apt-get install chrony -y >/dev/null 2>&1

    cp ./config/chrony.conf /etc/chrony/chrony.conf

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            NTP_SERVER='time1.tencentyun.com time2.tencentyun.com time3.tencentyun.com time4.tencentyun.com time5.tencentyun.com'
        fi
    fi

    for SERVER in ${NTP_SERVER}; do
        echo "server ${SERVER} iburst" >> /etc/chrony/chrony.conf
    done

    systemctl restart chronyd.service

    # 确保 NTP 同步完成
    sleep 6

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• NTP 同步状态（系统同步状态、时钟偏移等）"
        chronyc tracking
        msg_notic '\n%s\n' "• NTP 时间源（时间源列表及其状态）"
        chronyc sources
        msg_notic '\n%s\n' "• 配置文件（/etc/chrony/chrony.conf）"
        grep -Ev '^#|^$' /etc/chrony/chrony.conf | uniq
    else
        msg_succ '%s\n' "操作完成！"
    fi

    ((STATS++))
}
