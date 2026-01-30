#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_debugshell()
{
    msg_info '\n%s\n' "[${STATS}] 禁用 Debug Shell 服务"

    VERIFY=${VERIFY:-'Y'}

    systemctl stop debug-shell.service >/dev/null 2>&1
    systemctl mask -f debug-shell.service >/dev/null 2>&1

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 服务状态（debug-shell.service）"
        systemctl status debug-shell.service --no-pager
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
