#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

export LC_ALL=C.UTF-8

set -u -o pipefail

# 颜色代码
# shellcheck disable=SC2155
COLOR_INFO=$(tput setaf 6)$(tput bold)
readonly COLOR_INFO
COLOR_NOTICE=$(tput setaf 3)$(tput bold)
readonly COLOR_NOTICE
COLOR_SUCCESS=$(tput setaf 2)$(tput bold)
readonly COLOR_SUCCESS
COLOR_ERROR=$(tput setaf 1)$(tput bold)
readonly COLOR_ERROR
COLOR_RESET=$(tput sgr0)
readonly COLOR_RESET

# 检查权限
if (( EUID != 0 )); then
    printf '%s\n' "${COLOR_ERROR}Narsil 必须以 root 身份执行！${COLOR_RESET}" >&2
    exit 1
fi

# 检查系统
if ! grep -Eqi "Ubuntu" /etc/os-release; then
    printf '%s\n' "${COLOR_ERROR}Narsil 仅适用于 Ubuntu 系统！${COLOR_RESET}" >&2
    exit 1
fi

# 设置日志
function setup_logging()
{
    # 确保日志目录存在
    mkdir -p logs

    # 日志路径
    LOGFILE="logs/narsil-$(date +%Y%m%d-%s).log"

    # 创建日志文件
    truncate -s0 "${LOGFILE}"

    # 将所有输出同时发送到日志文件和标准输出。
    # 输出到 1 会同时发送到标准输出和日志文件。
    # 输出到 2 会同时发送到标准错误和日志文件。
    # 输出到 3 仅发送到标准输出。
    # 输出到 4 仅发送到标准错误。
    # 输出到 5 仅发送到日志文件。
    # shellcheck disable=SC2094
    exec \
        3>&1 \
        4>&2 \
        5>> "${LOGFILE}" \
        > >(tee -a "${LOGFILE}") \
        2> >(tee -a "${LOGFILE}" >&2)
}

# 单个参数原样返回，多个参数通过 printf 格式化。
# 第一个参数是用于存储结果的变量名。
function msg_format()
{
    local _VAR
    _VAR="$1"
    shift
    if (( $# > 1 )); then
        # shellcheck disable=SC2059
        printf -v "${_VAR}" "$@"
    else
        printf -v "${_VAR}" "%s" "$1"
    fi
}

function msg_info()
{
    local MSG
    msg_format MSG "$@"
    if [[ -n ${LOGFILE:-} ]] && [[ -e /dev/fd/5 ]]; then
        printf '%s' "${MSG}" >&5
    fi
    if [[ -e /dev/fd/3 ]]; then
        printf '%s%s%s' "${COLOR_INFO}" "${MSG}" "${COLOR_RESET}" >&3
    else
        printf '%s%s%s' "${COLOR_INFO}" "${MSG}" "${COLOR_RESET}"
    fi
}

function msg_notic()
{
    local MSG
    msg_format MSG "$@"
    if [[ -n ${LOGFILE:-} ]] && [[ -e /dev/fd/5 ]]; then
        printf '%s' "${MSG}" >&5
    fi
    if [[ -e /dev/fd/3 ]]; then
        printf '%s%s%s' "${COLOR_NOTICE}" "${MSG}" "${COLOR_RESET}" >&3
    else
        printf '%s%s%s' "${COLOR_NOTICE}" "${MSG}" "${COLOR_RESET}"
    fi
}

function msg_succ()
{
    local MSG
    msg_format MSG "$@"
    if [[ -n ${LOGFILE:-} ]] && [[ -e /dev/fd/5 ]]; then
        printf '%s' "${MSG}" >&5
    fi
    if [[ -e /dev/fd/3 ]]; then
        printf '%s%s%s' "${COLOR_SUCCESS}" "${MSG}" "${COLOR_RESET}" >&3
    else
        printf '%s%s%s' "${COLOR_SUCCESS}" "${MSG}" "${COLOR_RESET}"
    fi
}

function msg_error()
{
    local MSG
    msg_format MSG "$@"
    if [[ -n ${LOGFILE:-} ]] && [[ -e /dev/fd/5 ]]; then
        printf '%s' "${MSG}" >&5
    fi
    if [[ -e /dev/fd/4 ]]; then
        printf '%s%s%s' "${COLOR_ERROR}" "${MSG}" "${COLOR_RESET}" >&4
    else
        printf '%s%s%s' "${COLOR_ERROR}" "${MSG}" "${COLOR_RESET}" >&2
    fi
}

# shellcheck disable=SC1091
source narsil.conf

# shellcheck disable=SC1090
for SCRIPTS in scripts/narsil-*.sh; do
    [[ -f ${SCRIPTS} ]] || break
    source "${SCRIPTS}"
done

# shellcheck disable=SC2034
function narsil_logo()
{
    msg_info '\n%s\n' '   ██╗      ███╗   ██╗  █████╗  ██████╗  ███████╗ ██╗ ██╗     '
    msg_info '%s\n'   '   ╚██╗     ████╗  ██║ ██╔══██╗ ██╔══██╗ ██╔════╝ ██║ ██║     '
    msg_info '%s\n'   '    ╚██╗    ██╔██╗ ██║ ███████║ ██████╔╝ ███████╗ ██║ ██║     '
    msg_info '%s\n'   '    ██╔╝    ██║╚██╗██║ ██╔══██║ ██╔══██╗ ╚════██║ ██║ ██║     '
    msg_info '%s\n'   '   ██╔╝     ██║ ╚████║ ██║  ██║ ██║  ██║ ███████║ ██║ ███████╗'
    msg_info '%s\n\n' '   ╚═╝      ╚═╝  ╚═══╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚══════╝ ╚═╝ ╚══════╝'
    msg_info '%s\n'   'Narsil 是一个系统安全加固工具，可以帮助强化系统安全，防止未授权的访问与攻击'
    msg_info '%s\n'   '使用前请先阅读使用说明，项目地址：https://github.com/seatonjiang/narsil'

    STATS=1
}

function narsil_help()
{
    printf '%s\n' "${COLOR_NOTICE}用法：${COLOR_RESET}"
    printf '%s\n\n' "   sudo bash $0 [选项]"
    printf '%s\n' "${COLOR_NOTICE}选项：${COLOR_RESET}"
    printf '%s\n' "${COLOR_SUCCESS}   -c, --clear${COLOR_RESET}            清除系统日志文件"
    printf '%s\n' "${COLOR_SUCCESS}   -d, --docker${COLOR_RESET}           安装 Docker 服务并设置镜像源"
    printf '%s\n' "${COLOR_SUCCESS}   -f, --fdisk${COLOR_RESET}            交互式挂载数据磁盘"
    printf '%s\n' "${COLOR_SUCCESS}   -l, --lighthouse${COLOR_RESET}       删除腾讯云轻量服务器专属用户和组"
    printf '%s\n' "${COLOR_SUCCESS}   -n, --hostname${COLOR_RESET}         更改系统主机名"
    printf '%s\n' "${COLOR_SUCCESS}   -p, --port${COLOR_RESET}             修改 SSH 端口"
    printf '%s\n' "${COLOR_SUCCESS}   -r, --removeagent${COLOR_RESET}      卸载腾讯云服务器监控软件"
    printf '%s\n' "${COLOR_SUCCESS}   -s, --swap${COLOR_RESET}             添加交换空间"
    printf '%s\n' "${COLOR_SUCCESS}   -h, --help${COLOR_RESET}             获取命令帮助并退出"

    printf '\n%s\n' "使用过程中如果遇到问题，可以提交问题到 ${COLOR_SUCCESS}https://github.com/seatonjiang/narsil/issues${COLOR_RESET}"
}

function narsil_auto_check()
{
    if [ -e ./.narsil ]; then
        msg_error '%s\n' "Narsil 自动加固已完成，但可以带参数使用其他功能，执行 \"sudo bash $0 -h\" 查看参数说明。"
        exit 1
    fi
}

function narsil_reboot()
{
    touch .narsil
    printf '\n%s%s\n%s%s\n' "${COLOR_INFO}" \
    "Narsil 已加固完成，系统即将自动重启。" \
    "本次执行的日志已保存至 ${LOGFILE}" \
    "${COLOR_RESET}" >&3
    reboot
}

# 二次确认
function narsil_reconfirm()
{
    msg_info '\n%s' '按任意键开始执行或按 Ctrl+C 取消执行...'
    read -rsn1
    echo
}

function narsil_auto()
{
    setup_logging
    narsil_auto_check
    clear
    narsil_logo
    narsil_reconfirm
    narsil_ntpserver
    narsil_dnsserver
    narsil_timezone
    narsil_tcpbbr
    narsil_timeout
    narsil_useradd
    narsil_limits
    narsil_sshdconfig
    narsil_logindefs
    narsil_apport
    narsil_debugshell
    narsil_ctrlaltdel
    narsil_removepackages
    narsil_banner
    narsil_reboot
}

if [ $# -eq 0 ];then
    narsil_auto
    exit 0
fi

while :; do
    [ -z "$1" ] && exit 0;
    case $1 in
        -c|--clear)
            clear
            narsil_logo
            narsil_clearlogs
            exit 0
        ;;
        -d|--docker)
            setup_logging
            clear
            narsil_logo
            narsil_docker
            exit 0
        ;;
        -f|--fdisk)
            setup_logging
            clear
            narsil_logo
            narsil_fdisk
            exit 0
        ;;
        -l|--lighthouse)
            clear
            narsil_logo
            narsil_lighthouse
            exit 0
        ;;
        -n|--hostname)
            clear
            narsil_logo
            narsil_hostname
            exit 0
        ;;
        -p|--port)
            clear
            narsil_logo
            narsil_sshport
            exit 0
        ;;
        -r|--removeagent)
            clear
            narsil_logo
            narsil_removeagent
            exit 0
        ;;
        -s|--swap)
            clear
            narsil_logo
            narsil_swap
            exit 0
        ;;
        -h|--help)
            narsil_help
            exit 0
        ;;
        *)
            printf '%s\n' "${COLOR_ERROR}选项 \"$1\" 不存在，可以执行 \"sudo bash $0 -h\" 查看说明。${COLOR_RESET}"
            exit 1
        ;;
    esac
done
