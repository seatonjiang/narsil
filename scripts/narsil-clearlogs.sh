#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_clearlogs()
{
    msg_notic '\n%s\n\n' "正在清理系统日志文件，请稍候..."

    find /var/log -type f -regex '.*\.[0-9]$' -delete
    find /var/log -type f -regex '.*-[0-9]*$' -delete
    find /var/log -type f -regex '.*\.gz$' -delete

    while IFS= read -r -d '' logfiles
    do
        true > "${logfiles}"
    done < <(find /var/log/ -type f -print0)

    if [ -d /var/backups ]; then
        find /var/backups -type f -delete
    fi

    apt-get autoclean -y >/dev/null 2>&1
    apt-get autoremove -y >/dev/null 2>&1

    msg_succ '%s\n\n' "系统日志文件已清理完成！"
}
