#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_ctrlaltdel()
{
    msg_info '\n%s\n' "[${STATS}] 禁用 Ctrl-Alt-Delete 功能"

    VERIFY=${VERIFY:-'Y'}

    systemctl stop ctrl-alt-del.target >/dev/null 2>&1
    systemctl mask -f ctrl-alt-del.target >/dev/null 2>&1

    sed -i 's/^#CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' /etc/systemd/system.conf

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 服务状态（ctrl-alt-del.target）"
        systemctl status ctrl-alt-del.target --no-pager
        msg_notic '\n%s\n' "• 配置文件（/etc/systemd/system.conf）"
        grep CtrlAltDelBurstAction /etc/systemd/system.conf
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
