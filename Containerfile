# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}
LABEL \
        org.opencontainers.image.title="n8n" \
        org.opencontainers.image.description="Workflow Automation platform" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/n8n" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-n8n/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-n8n.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    N8N_VERSION=1.123.0

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    CONTAINER_ENABLE_MESSAGING=FALSE \
    NGINX_SITE_ENABLED=n8n \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
    NGINX_WEBROOT=/app \
    NGINX_WORKER_PROCESSES=1 \
    IMAGE_NAME="container/n8n" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-n8n/"

RUN echo "" && \
    N8N_BUILD_DEPS_ALPINE=" \
                            build-base \
                            python3 \
                        " \
                    && \
    N8N_RUN_DEPS_ALPINE=" \
                            graphicsmagick \
                            git \
                            nodejs \
                            npm \
                            openssh-client \
                        " \
                    && \
    \
    source /container/base/functions/container/build && \
    container_build_log image  && \
    create_user n8n 5678 n8n 5678 /app && \
    package update && \
    package upgrade && \
    package install \
                        N8N_BUILD_DEPS \
                        N8N_RUN_DEPS \
                        && \
    \
    mkdir -p /app && \
    npm_config_user=root npm install -g \
                                        n8n@${N8N_VERSION} \
                                        typescript \
                                        && \
    \
    container_build_log add "n8n" "${N8N_VERSION}" "npm" && \
    package remove \
                    N8N_BUILD_DEPS \
                    && \
    package cleanup

WORKDIR /app/

EXPOSE 5678

COPY rootfs /
