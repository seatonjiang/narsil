#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

# shellcheck disable=SC2001
# shellcheck disable=SC2010
# shellcheck disable=SC2143
function narsil_fdisk()
{
    if [ -z "$(fdisk -l | grep -o "Disk /dev/.*vd[b-z]")" ];then
        msg_notic '\n%s\n\n' "未检测到可挂载的磁盘，已跳过挂载步骤！"
        exit 1
    fi

    msg_notic '\n%s\n' "[1] 列出所有可用磁盘"
    fdisk -l | grep -o "Disk /dev/.*vd[b-z]" | sed 's/Disk //'

    msg_notic '\n%s' "[2] 请输入要操作的磁盘（示例 /dev/vdb）："
    while :; do
        read -r DISK
        if [ -z "$(echo "${DISK}" | grep '^/dev/.*vd[b-z]')" ]; then
            msg_error '%s' "格式错误，请重新输入："
        else
            if [ -z "$(fdisk -l | grep -o "Disk /dev/.*vd[b-z]" | sed 's/Disk //' | grep "^${DISK}$")" ]; then
                msg_error '%s' "未找到磁盘，请重新输入："
            else
                fdisk_mounted
                break
            fi
        fi
    done

    msg_notic '\n%s\n' "[3] 正在对磁盘进行分区并格式化"
    fdisk_mkfs "${DISK}" >/dev/null 2>&1
    msg_succ '%s\n' "成功，磁盘已分区并格式化！"

    msg_notic '\n%s' "[4] 请输入挂载点路径（默认 /data）："
    while :; do
        read -r MOUNT
        MOUNT=${MOUNT:-"/data"}
        if [ -z "$(echo "${MOUNT}" | grep '^/')" ]; then
            msg_error '%s' "目录必须以 / 开头，请重新输入："
        else
            mkdir "${MOUNT}" >/dev/null 2>&1
            mount "${DISK}1" "${MOUNT}"
            break
        fi
    done
    msg_succ '%s\n' "成功，挂载完成！"

    msg_notic '\n%s\n' "[5] 正在将挂载信息写入 /etc/fstab"
    if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ] || [ -n "$(wget -qO- -t1 -T2 100.100.100.200)" ]; then
        SDISK=$(echo "${DISK}" | grep -o "/dev/.*vd[b-z]" | awk -F"/" '{print $(NF)}')
        SOFTLINK=$(ls -l /dev/disk/by-id | grep "${SDISK}1" | awk -F" " '{print $(NF-2)}')
        sed -i "/${SOFTLINK}/d" /etc/fstab
        echo "/dev/disk/by-id/${SOFTLINK} ${MOUNT} ext4 defaults 0 2" >> /etc/fstab
    else
        sed -i "/${DISK}1/d" /etc/fstab
        echo "${DISK}1 ${MOUNT} ext4 defaults 0 2" >> /etc/fstab
    fi
    msg_succ '%s\n' "成功，已将挂载信息写入 /etc/fstab！"

    msg_notic '\n%s\n' "[6] 显示磁盘空间使用情况"
    df -Th

    msg_notic '\n%s\n' "[7] 显示配置文件（/etc/fstab）"
    grep -Ev '^#|^$' /etc/fstab | uniq

    printf '\n%s%s\n%s%s\n\n' "${COLOR_INFO}" \
    "操作完成，数据磁盘已挂载！" \
    "本次执行的日志已保存至 ${LOGFILE}" \
    "${COLOR_RESET}" >&3
}

function fdisk_mounted()
{
    while mount | grep -q "${DISK}";do
        msg_error '\n%s\n' "[!] 此磁盘已被挂载"
        mount | grep "${DISK}"
        msg_error '\n%s' "[!] 强制卸载磁盘？ [y/n]："
        while :; do
        read -r UMOUNT
        if [[ ! "${UMOUNT}" =~ ^[y,n,Y,N]$ ]]; then
            msg_error '%s' "[!] 格式错误，请重新输入："
        else
            if [ "${UMOUNT}" == 'y' ] || [ "${UMOUNT}" == 'Y' ]; then
                for i in $(mount | grep "${DISK}" | awk '{print $3}');do
                    fuser -km "$i"
                    umount "$i"
                    TEMP=$(echo "${DISK}" | sed 's;/;\\\/;g')
                    sed -i -e "/^$TEMP/d" /etc/fstab
                done
                msg_succ '%s\n' "成功，磁盘已卸载！"
            else
                exit
            fi
            break
        fi
        done
        msg_error '\n%s' "[!] 准备格式化磁盘？ [y/n]："
        while :; do
        read -r CHOICE
        if [[ ! "${CHOICE}" =~ ^[y,n,Y,N]$ ]]; then
            msg_error '%s' "[!] 格式错误，请重新输入："
        else
            if [ "${CHOICE}" == 'y' ] || [ "${CHOICE}" == 'Y' ]; then
                dd if=/dev/zero of="${DISK}" bs=512 count=1 >/dev/null 2>&1
                sync
                msg_succ '%s\n' "成功，磁盘已格式化！"
            else
                exit
            fi
            break
        fi
        done
    done
}

function fdisk_mkfs()
{
    fdisk "$1" << EOF
n
p
1


wq
EOF

    sleep 3
    partprobe
    mkfs -t ext4 "${1}1"
}
