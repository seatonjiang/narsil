#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_swap()
{
    MEMORY=$(free -m | awk '/Mem:/{print $2}')

    if [ "${MEMORY}" -le 1280 ]; then
        MEMORY_LEVEL=1G
    elif [ "${MEMORY}" -gt 1280 ] && [ "${MEMORY}" -le 2500 ]; then
        MEMORY_LEVEL=2G
    elif [ "${MEMORY}" -gt 2500 ] && [ "${MEMORY}" -le 3500 ]; then
        MEMORY_LEVEL=3G
    elif [ "${MEMORY}" -gt 3500 ] && [ "${MEMORY}" -le 4500 ]; then
        MEMORY_LEVEL=4G
    elif [ "${MEMORY}" -gt 4500 ] && [ "${MEMORY}" -le  8000 ]; then
        MEMORY_LEVEL=6G
    elif [ "${MEMORY}" -gt 8000 ]; then
        MEMORY_LEVEL=8G
    fi

    # 检查并删除 swap.img 文件
    if [ -f /swap.img ]; then
        msg_notic '\n%s\n' "发现 /swap.img 文件，正在移除..."
        swapoff /swap.img >/dev/null 2>&1
        sed -i '\#/swap.img#d' /etc/fstab
        rm -f /swap.img
    fi

    msg_notic '\n%s\n' "正在添加交换空间，请稍候..."

    if [ "$(free -m | awk '/Swap:/{print $2}')" == '0' ]; then
        fallocate -l "${MEMORY_LEVEL}" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile >/dev/null 2>&1
        swapon /swapfile
        sed -i "/swap/d" /etc/fstab
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi

    # 配置 vm.swappiness，如果配置文件中不存在则添加，存在则修改
    if ! grep -q -E "^\s*vm\.swappiness" /etc/sysctl.conf; then
        {
            echo -e '\n# Setting the swappiness'
            echo "vm.swappiness=10"
        } >> /etc/sysctl.conf
    else
        sed -i "s/^\s*vm\.swappiness\s*=.*/vm.swappiness=10/" /etc/sysctl.conf
    fi

    # 配置 vm.vfs_cache_pressure，如果配置文件中不存在则添加，存在则修改
    if ! grep -q -E "^\s*vm\.vfs_cache_pressure" /etc/sysctl.conf; then
        {
            echo -e '\n# Setting the vfs_cache_pressure'
            echo "vm.vfs_cache_pressure=50"
        } >> /etc/sysctl.conf
    else
        sed -i "s/^\s*vm\.vfs_cache_pressure\s*=.*/vm.vfs_cache_pressure=50/" /etc/sysctl.conf
    fi

    sysctl -p >/dev/null 2>&1

    msg_notic '\n%s\n' "[1/3] 显示交换空间"
    swapon --show
    msg_notic '\n%s\n' "[2/3] 显示内存信息"
    free -h
    msg_notic '\n%s\n' "[3/3] 显示配置文件（/etc/fstab）"
    grep -Ev '^#|^$' /etc/fstab | uniq

    msg_succ '\n%s\n\n' "交换空间已添加完成！"
}
