#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_timeout()
{
    msg_info '\n%s\n' "[${STATS}] 配置系统超时自动退出"

    VERIFY=${VERIFY:-'Y'}
    LOGOUT_TIME=${LOGOUT_TIME:-'300'}

    if ! grep -nqri "TMOUT" /etc/profile.d/; then
        echo "export TMOUT=${LOGOUT_TIME}" > /etc/profile.d/auto-logout.sh
        echo "readonly TMOUT" >> /etc/profile.d/auto-logout.sh
        chmod 0644 /etc/profile.d/auto-logout.sh

        if [[ ${VERIFY^^} == 'Y' ]]; then
            msg_notic '\n%s\n' "• 配置文件（/etc/profile）"
            grep -nri "TMOUT" /etc/profile.d/
        else
            msg_succ '%s\n' "操作完成！"
        fi
    else
        msg_succ '%s\n' "跳过，此配置已存在！"
    fi

    sleep 1

    ((STATS++))
}
