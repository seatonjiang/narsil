#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_removeagent()
{
    msg_notic '\n%s\n\n' "正在卸载腾讯云服务器监控组件，请稍候..."

    # 卸载 BaradAgent
    /usr/local/qcloud/monitor/barad/admin/uninstall.sh >/dev/null 2>&1

    # 卸载 Sgagent
    /usr/local/qcloud/stargate/admin/uninstall.sh >/dev/null 2>&1

    # 卸载 TatAgent
    ./config/tat-agent-uninstall.sh >/dev/null 2>&1

    # 卸载 YunJing（需要手动输入验证码）
    if [ -w '/usr' ]; then /usr/local/qcloud/YunJing/uninst.sh ; else /var/lib/qcloud/YunJing/uninst.sh ; fi

    msg_succ '\n%s\n\n' "所有监控组件已卸载完成！"
}
