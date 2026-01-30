#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_sshport()
{
    if [ ! -e "/etc/ssh/sshd_config" ];then
        msg_error '\n%s\n' "找不到 sshd 配置文件！"
        exit 1
    fi

    OLD_SSH_PORT=$( grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1 )

    if [ -z "${OLD_SSH_PORT}" ];then
        OLD_SSH_PORT='22'
    fi

    msg_notic '\n%s' "[1/2] 请输入 SSH 端口（范围 10000 到 65535，当前为 ${OLD_SSH_PORT}）："

    while :; do
        read -r NEW_SSH_PORT
        NPTSTATUS=$( ss -ltnH | awk -v port="${NEW_SSH_PORT}" '$4 ~ ":"port"$"' )
        if [ -n "${NPTSTATUS}" ];then
            msg_error '%s' "端口已被占用，请重新输入（范围 10000 到 65535）："
        elif [[ "${NEW_SSH_PORT}" -ne 22 && ( "${NEW_SSH_PORT}" -lt 10000 || "${NEW_SSH_PORT}" -gt 65535 ) ]]; then
            msg_error '%s' "请重新输入（范围 10000 到 65535）："
        else
            break
        fi
    done

    if [[ "${OLD_SSH_PORT}" != "22" ]]; then
        sed -i "s@^Port.*@Port ${NEW_SSH_PORT}@" /etc/ssh/sshd_config
    else
        sed -i "s@^#Port.*@&\nPort ${NEW_SSH_PORT}@" /etc/ssh/sshd_config
        sed -i "s@^Port.*@Port ${NEW_SSH_PORT}@" /etc/ssh/sshd_config
    fi

    msg_succ '%s\n' "成功，SSH 端口修改完成！"
    msg_notic '\n%s\n' "[2/2] 重启服务以生效"
    systemctl daemon-reload >/dev/null 2>&1
    systemctl restart ssh.service >/dev/null 2>&1
    msg_succ '%s\n\n' "成功，云服务器需要在安全组中放通 [TCP:${NEW_SSH_PORT}] 端口！"
}
