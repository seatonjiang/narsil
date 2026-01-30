#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_logindefs()
{
    msg_info '\n%s\n' "[${STATS}] 配置用户登录策略"

    VERIFY=${VERIFY:-'Y'}

    # 设置密码最大使用天数为 30 天
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 30/' /etc/login.defs

    # 设置密码最小使用天数为 1 天（防止用户立即修改新密码）
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/' /etc/login.defs

    # 设置密码最小长度为 12 位
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/' /etc/login.defs

    # 设置密码到期前 7 天开始警告用户
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs

    # 禁止系统为用户自动创建家目录
    sed -i 's/^.*DEFAULT_HOME.*/DEFAULT_HOME no/' /etc/login.defs

    # 指定密码加密算法为 SHA512
    sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs

    # 禁止系统自动创建与用户名同名的私有用户组
    sed -i 's/^USERGROUPS_ENAB.*/USERGROUPS_ENAB no/' /etc/login.defs

    # 设置超级用户（root）的 PATH 环境变量
    sed -i 's@^.*ENV_SUPATH.*@ENV_SUPATH PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin@' /etc/login.defs

    # 设置普通用户的 PATH 环境变量
    sed -i 's@^.*ENV_PATH.*@ENV_PATH PATH=/usr/local/bin:/usr/bin:/bin:/snap/bin@' /etc/login.defs

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• 配置文件（/etc/login.defs）"
        grep -Ev '^#|^$' /etc/login.defs | uniq
    else
        msg_succ '%s\n' "操作完成！"
    fi

    sleep 1

    ((STATS++))
}
