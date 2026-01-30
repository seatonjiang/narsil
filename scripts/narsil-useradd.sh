#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_useradd()
{
    msg_info '\n%s\n' "[${STATS}] 优化用户添加策略"

    VERIFY=${VERIFY:-'Y'}

    # 创建新用户时，默认禁用登录，使用 `usermod -s /bin/bash user` 来更改 shell
    sed -i 's/SHELL=.*/SHELL=\/bin\/false/' /etc/default/useradd

    # 密码过期 30 天后，账户将被禁用
    sed -i 's/INACTIVE=.*/INACTIVE=30/' /etc/default/useradd

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 配置文件（/etc/default/useradd）"
        grep -Ev '^#|^$' /etc/default/useradd | uniq
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
