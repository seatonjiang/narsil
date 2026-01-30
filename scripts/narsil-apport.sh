#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_apport()
{
    msg_info '\n%s\n' "[${STATS}] 禁用 Apport 服务"

    VERIFY=${VERIFY:-'Y'}

    if [ -f /etc/default/apport ]; then
        sed -i 's/enabled=.*/enabled=0/' /etc/default/apport
        systemctl stop apport.service >/dev/null 2>&1
        systemctl mask apport.service >/dev/null 2>&1

        if [[ ${VERIFY^^} == 'Y' ]]; then
            msg_notic '\n%s\n' "• 服务状态（apport.service）"
            systemctl status apport.service --no-pager
            msg_notic '\n%s\n' "• 配置文件（/etc/default/apport）"
            grep -Ev '^#|^$' /etc/default/apport | uniq
        else
            msg_succ '%s\n' "操作完成！"
        fi
    else
        msg_succ '%s\n' "服务不存在，跳过!"
    fi

    sleep 1

    ((STATS++))
}
