FROM ruby:2.5.5-slim AS builder
# note: zammad is currently incompatible to alpine because of:
# https://github.com/docker-library/ruby/issues/113

ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive

ENV GIT_BRANCH stable
ENV ZAMMAD_TMP_DIR /tmp/zammad-${GIT_BRANCH}

ENV GOSU_VERSION 1.11
ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_READY_FILE ${ZAMMAD_DIR}/tmp/zammad.ready
ENV ZAMMAD_USER zammad

# install deps
RUN apt-get update && apt-get install -y --no-install-recommends build-essential curl git libimlib2-dev libpq-dev inotify-tools
RUN rm -rf /var/lib/apt/lists/*

# copy only what installation requires
RUN mkdir ${ZAMMAD_TMP_DIR}
COPY ./nomad/Gemfile ${ZAMMAD_TMP_DIR}/Gemfile
COPY ./nomad/Gemfile.lock ${ZAMMAD_TMP_DIR}/Gemfile.lock
COPY ./nomad/VERSION ${ZAMMAD_TMP_DIR}/VERSION

RUN mkdir -p ${ZAMMAD_TMP_DIR}/config
COPY ./nomad/config/ ${ZAMMAD_TMP_DIR}/config
RUN mkdir -p ${ZAMMAD_TMP_DIR}/script
COPY ./nomad/script/ ${ZAMMAD_TMP_DIR}/script
RUN mkdir -p ${ZAMMAD_TMP_DIR}/contrib/packager.io
COPY ./nomad/contrib/packager.io/ ${ZAMMAD_TMP_DIR}/contrib/packager.io

# COPY ./nomad ${ZAMMAD_TMP_DIR}
# Setup dependencies
COPY setup.sh /tmp
COPY nsa.sh /tmp

RUN chmod +x /tmp/nsa.sh
RUN chmod +x /tmp/setup.sh && /tmp/nsa.sh ${ZAMMAD_TMP_DIR} /tmp/setup.sh install

# =================================================================
#  Container
# =================================================================
FROM ruby:2.5.5-slim

ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive

# install deps
RUN apt-get update && apt-get install -y --no-install-recommends curl libimlib2 libimlib2-dev libpq5 nginx rsync vim inotify-tools
RUN rm -rf /var/lib/apt/lists/*

# install gosu
ENV GOSU_VERSION 1.11
RUN \
    curl -s -J -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true


ENV GIT_BRANCH stable
ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_READY_FILE ${ZAMMAD_DIR}/tmp/zammad.ready
ENV ZAMMAD_TMP_DIR /tmp/zammad-${GIT_BRANCH}
ENV ZAMMAD_CODEBASE_DIR /tmp/zammad-codebase
ENV ZAMMAD_USER zammad


COPY setup.sh /tmp
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh run

COPY --from=builder ${ZAMMAD_TMP_DIR} ${ZAMMAD_TMP_DIR}
COPY --from=builder /usr/local/bundle /usr/local/bundle

COPY ./nomad ${ZAMMAD_CODEBASE_DIR}
# docker init
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR ${ZAMMAD_DIR}
