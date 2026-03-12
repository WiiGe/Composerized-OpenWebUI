#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 设置默认的 Open WebUI 镜像标签（可以设为 latest 或具体版本）
OPENWEBUI_TAG="latest"
IMAGE_NAME="ghcr.io/open-webui/open-webui:${OPENWEBUI_TAG}"

echo "正在检查 Open WebUI (${IMAGE_NAME}) 中的 Playwright 版本..."

# 1. 运行一个临时容器来获取 Playwright 版本
# 必须使用 --entrypoint 覆盖默认启动命令，否则容器可能会启动 Web 服务
PLAYWRIGHT_VERSION=$(sudo docker run --rm --entrypoint "" "$IMAGE_NAME" pip show playwright | grep Version | cut -d " " -f 2)

if [ -z "$PLAYWRIGHT_VERSION" ]; then
    echo "错误：无法获取 Playwright 版本。"
    exit 1
fi

echo "检测到 Playwright 版本: $PLAYWRIGHT_VERSION"

# 2. 获取 Playwright 镜像的发行版（noble/jammy 等）
# 通过检查容器内的 /etc/os-release 文件
PLAYWRIGHT_DISTRO=$(sudo docker run --rm --entrypoint "" "$IMAGE_NAME" cat /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f 2)

if [ -z "$PLAYWRIGHT_DISTRO" ]; then
    echo "警告：无法获取发行版，默认使用 noble"
    PLAYWRIGHT_DISTRO="noble"
else
    echo "检测到 Playwright 镜像发行版: $PLAYWRIGHT_DISTRO"
fi

# 3. 将版本号和发行版导出到 .env 文件，供 docker-compose 使用
ENV_FILE="${PROJECT_ROOT}/.env"
ENV_EXAMPLE="${PROJECT_ROOT}/env.example"

# 更新环境变量的函数
update_env_var() {
    local key=$1
    local value=$2
    local env_file=$3
    
    if grep -q "^${key}=" "$env_file"; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$env_file"
    else
        echo "${key}=${value}" >> "$env_file"
    fi
}

if [ -f "$ENV_FILE" ]; then
    update_env_var "PLAYWRIGHT_VERSION" "$PLAYWRIGHT_VERSION" "$ENV_FILE"
    update_env_var "PLAYWRIGHT_DISTRO" "$PLAYWRIGHT_DISTRO" "$ENV_FILE"
else
    # 如果 .env 文件不存在，则使用 .env.example 作为模板创建
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        update_env_var "PLAYWRIGHT_VERSION" "$PLAYWRIGHT_VERSION" "$ENV_FILE"
        update_env_var "PLAYWRIGHT_DISTRO" "$PLAYWRIGHT_DISTRO" "$ENV_FILE"
    else
        echo "PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION}" > "$ENV_FILE"
        echo "PLAYWRIGHT_DISTRO=${PLAYWRIGHT_DISTRO}" >> "$ENV_FILE"
    fi
fi

echo "已更新 .env 文件"


# (可选) 3. 启动 Docker Compose
# echo "正在启动服务..."
# docker-compose up -d