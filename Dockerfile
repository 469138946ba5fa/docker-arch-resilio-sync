# ubuntu 滚动版，追求新颖，不稳定
FROM docker.io/library/ubuntu:rolling

# 构建参数，只有构建阶段有效，构建完成后消失
# init_system.sh 所需临时环境变量
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ='Asia/Shanghai'

# 固化运行环境变量，全局构建和容器运行都可用，字符支持，安装目录，以及启动路径
# init_system.sh 所需固化环境 LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    LANGUAGE=zh_CN.UTF-8 \
    LC_CTYPE=zh_CN.UTF-8

# 添加常用LABEL（根据需要修改）添加标题 版本 作者 代码仓库 镜像说明，方便优化
LABEL org.opencontainers.image.description='安装 Resilio Sync 封装特殊需求自用测试容器' \
      org.opencontainers.image.title='Multi-arch Resilio Sync' \
      org.opencontainers.image.version='1.0.0' \
      org.opencontainers.image.authors='469138946ba5fa <af5ab649831964@gmail.com>' \
      org.opencontainers.image.source='https://github.com/469138946ba5fa/docker-arch-resilio-sync' \
      org.opencontainers.image.licenses='MIT'

# 设置工作目录 '/root/Resilio Sync' 仅用于 Resilio Sync 数据挂载（保持干净）
WORKDIR /root/'Resilio Sync'

# 复制所有脚本到 /usr/local/bin（保持工作目录干净）
# 执行安装与配置脚本（全部以 root 执行）
COPY scripts/ /usr/local/bin/
COPY sources/ /usr/local/src/

# 执行 初始化 安装
# 保留日志脚本 common.sh
# 启动脚本 start_test.sh
RUN cd /usr/local/bin/ && \
    chmod -v a+x *.sh && \
    analyze_size.sh before-install && \
    init_system.sh && \
    install_resilio-sync.sh && \
    analyze_size.sh after-install && \
    clean.sh && \
    rm -fv init_system.sh install_resilio-sync.sh clean.sh && \
    analyze_size.sh after-clean

# 使用 tini 作为入口，调用 entrypoint 脚本或者直接启动 /usr/local/bin/start_test.sh
ENTRYPOINT ["tini", "--"]
# 脚本执行
CMD [ "/usr/local/bin/start_resilio-sync.sh", "--config", "/usr/local/etc/resilio-sync/sync.conf" ]