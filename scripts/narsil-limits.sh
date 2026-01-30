#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_limits()
{
    msg_info '\n%s\n' "[${STATS}] 配置 Ulimit 以支持高并发场景"

    VERIFY=${VERIFY:-'Y'}

    if ! grep -qnri "# Narsil 资源限制配置" /etc/security/limits.conf; then
        sed -i 's/^# End of file*//' /etc/security/limits.conf
        {
            echo '# Narsil 资源限制配置'
            echo '* soft nofile 655350'
            echo '* hard nofile 655350'
            echo '* soft nproc  unlimited'
            echo '* hard nproc  unlimited'
            echo '* soft core   unlimited'
            echo '* hard core   unlimited'
        } >> /etc/security/limits.conf
    fi

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 配置文件（/etc/security/limits.conf）"
        grep -Ev '^#|^$' /etc/security/limits.conf | uniq
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
