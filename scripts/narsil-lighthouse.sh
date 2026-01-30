#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_lighthouse()
{
    msg_notic '\n%s\n\n' "正在删除腾讯云轻量服务器专属用户和组，请稍候..."

    userdel -r lighthouse >/dev/null 2>&1
    groupdel -f lighthouse >/dev/null 2>&1

    msg_succ '%s\n\n' "腾讯云轻量服务器专属用户和组已删除完成！"
}
