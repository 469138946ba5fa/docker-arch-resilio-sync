#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# 将日志输出重定向到日志文件
LOG_FILE="/var/log/jupyter_startup.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

log_info "Starting Resilio Sync service..."
mkdir -pv ${HOME}'/Resilio Sync/license'
mkdir -pv ${HOME}'/Resilio Sync/.sync'

if [ ! -d "/var/log" ]; then
  log_error "/var/log directory does not exist. Please check volume mounts."
  exit 1
fi

for cmd in rslsync; do
  if ! command_exists "${cmd}"; then
    log_error "${cmd} is not installed. Aborting."
    # exit 1
  fi
done

# --------- 检测 Resilio Sync ---------

# 如ResilioSyncPro.btskey文件不存在则复制
if [ ! -f ${HOME}'/Resilio Sync/license/ResilioSyncPro.btskey' ]; then
    log_info "Copy Resilio Sync file..."
    cp -afv /usr/local/src/ResilioSyncPro.btskey $HOME'/Resilio Sync/license'
fi

# --------- 启动 Resilio Sync ---------
log_info "Launching Resilio Sync on port 9999..."
rslsync --nodaemon $*