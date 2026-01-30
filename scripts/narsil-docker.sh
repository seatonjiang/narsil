#!/usr/bin/env bash
#
# Narsil - Ubuntu 系统安全加固工具
# Seaton Jiang <hi@seatonjiang.com>
#

function narsil_docker()
{
    # 检查是否已安装 Docker Engine
    if command -v docker >/dev/null 2>&1; then
        msg_notic '\n%s\n\n' "检测到 Docker Engine 已安装，已跳过安装步骤！"
        return 0
    fi

    msg_notic '\n%s\n\n' "正在安装 Docker Engine 服务，请稍候..."

    DOCKER_CE_REPO=${DOCKER_CE_REPO:-'https://mirrors.cloud.tencent.com/docker-ce'}
    VERIFY=${VERIFY:-'Y'}

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            DOCKER_CE_REPO='http://mirrors.tencentyun.com/docker-ce'
            DOCKER_HUB_MIRRORS='https://mirror.ccs.tencentyun.com'
        fi
    fi

    # 卸载旧版本
    for PKG in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        apt-get remove "${PKG}" -y >/dev/null 2>&1;
    done

    apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y >/dev/null 2>&1

    # 安装依赖
    apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
    curl -fsSL "${DOCKER_CE_REPO}"/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

    # 添加软件源
    echo "deb [arch=$(dpkg --print-architecture)] ${DOCKER_CE_REPO}/linux/ubuntu $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list

    # 安装 Docker Engine
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    mkdir -p /etc/docker

    if [ -n "${DOCKER_HUB_MIRRORS}" ]; then
        {
            echo '{'
            echo '  "registry-mirrors": ['
            echo "    \"${DOCKER_HUB_MIRRORS}\""
            echo '  ],'
            echo '  "log-driver": "json-file",'
            echo '  "log-opts": {'
            echo '    "max-size": "50m",'
            echo '    "max-file": "7"'
            echo '  }'
            echo '}'
        } > /etc/docker/daemon.json
    fi

    groupadd docker
    usermod -aG docker ubuntu

    systemctl restart docker.service
    systemctl enable docker.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• Docker 版本信息"
        docker version
        msg_notic '\n%s\n' "• Docker Compose 版本信息"
        docker compose version
    fi

    printf '\n%s%s\n%s%s\n\n' "${COLOR_INFO}" \
    "安装完成，请重新登录，然后使用 \"docker run hello-world\" 进行测试！" \
    "本次执行的日志已保存至 ${LOGFILE}" \
    "${COLOR_RESET}" >&3
}
