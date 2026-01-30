#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_banner()
{
    msg_info '\n%s\n' "[${STATS}] 添加登录展示系统状态功能"

    PROD_TIPS=${PROD_TIPS:-'Y'}

    # 禁用 motd-news
    sed -i 's/ENABLED=.*/ENABLED=0/' /etc/default/motd-news
    systemctl stop motd-news.timer >/dev/null 2>&1
    systemctl mask motd-news.timer >/dev/null 2>&1

    # 禁用所有 motd 脚本
    chmod -x /etc/update-motd.d/*

    # 复制自定义 motd 脚本
    cp ./config/banner/*-narsil-* /etc/update-motd.d/
    chmod +x /etc/update-motd.d/*-narsil-*

    apt-get install net-tools -y >/dev/null 2>&1

    # 移除 landscape-common
    apt-get remove landscape-common -y >/dev/null 2>&1

    # 开启生产环境提示
    if [[ ${PROD_TIPS^^} != 'Y' ]]; then
        chmod -x /etc/update-motd.d/20-aegis-footer
    fi

    msg_succ '%s\n' "操作完成！"

    sleep 1

    ((STATS++))
}
