#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_sshdconfig()
{
    msg_info '\n%s\n' "[${STATS}] 配置 OpenSSH 服务"

    SSH_PORT=${SSH_PORT:-'22'}
    VERIFY=${VERIFY:-'Y'}

    cp /etc/ssh/sshd_config /etc/ssh/sshd_config-"$(date +%Y%m%d-%s)".bak
    cp ./config/sshd_config /etc/ssh/sshd_config
    sed -i "s/.*Port.*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
    chown root:root /etc/ssh/sshd_config
    chmod 0600 /etc/ssh/sshd_config
    systemctl daemon-reload
    systemctl restart ssh.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 配置文件（/etc/ssh/sshd_config）"
        grep -Ev '^#|^$' /etc/ssh/sshd_config | uniq
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
