#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

log_info "Starting Resilio Sync environment setup..."

# 获取操作系统和架构信息
OS=$(uname -s)
ARCH=$(uname -m)

# 映射平台到官方命名
case "${OS}" in
  Linux)
    PLATFORM="linux"
    if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
      ARCH="arm64"
    elif [[ "${ARCH}" == "x86_64" ]]; then
      ARCH="x64"
    else
      log_error "Unsupported architecture: ${ARCH}"
      exit 1
    fi
    ;;
  *)
    log_error "Unsupported OS: ${OS}"
    exit 1
    ;;
esac

# 输出最终平台和架构
log_info "Platform: ${PLATFORM}"
log_info "Architecture: ${ARCH}"

# 拼接下载链接和校验码链接
TARGET_FILE="resilio-sync_${ARCH}.tar.gz"
URI_DOWNLOAD="https://download-cdn.resilio.com/stable/${PLATFORM}/${ARCH}/0/${TARGET_FILE}"
log_info "Download URL: ${URI_DOWNLOAD}"

# 如果文件不存在
if [[ ! -f "/tmp/${TARGET_FILE}" ]]; then
  log_info "Downloading file..."
  # 临时取消 set -e（如果你之前开启了严格模式）防止炸脚本
  set +e
  curl -L -C - --retry 3 --retry-delay 5 --progress-bar -o "/tmp/${TARGET_FILE}" "${URI_DOWNLOAD}"
  set -e
fi

# 安装 Resilio Sync
log_info "Installing Resilio Sync..."
tar xfv "/tmp/${TARGET_FILE}" -C /usr/local/bin rslsync
chmod -v a+x /usr/local/bin/rslsync
if [[ ! -d "/usr/local/etc/resilio-sync" ]]; then
  log_info "Copy file..."
  mv -fv /usr/local/src/resilio-sync /usr/local/etc/
fi

log_info "Resilio Sync setup is complete."
# 临时取消 set -e（如果你之前开启了严格模式）防止炸脚本
set +e
rslsync --version
set -e