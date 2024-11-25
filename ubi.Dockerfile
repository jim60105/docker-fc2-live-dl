# syntax=docker/dockerfile:1
ARG UID=1001
ARG VERSION=EDGE
ARG RELEASE=0

########################################
# Base stage
# Install Python and dependencies
########################################
FROM registry.access.redhat.com/ubi9/ubi-minimal AS base

ENV PYTHON_VERSION=3.11
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

RUN microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs -y install \
    python3.11 && \
    microdnf -y clean all && \
    ln -s /usr/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/bin/python3.11 /usr/bin/python

########################################
# Build stage
########################################
FROM base AS build

# Install build time dependencies
RUN microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs -y install \
    python3.11-pip findutils && \
    microdnf -y clean all

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /source

# Install under /root/.local
ENV PIP_USER="true"
ARG PIP_NO_WARN_SCRIPT_LOCATION=0
ARG PIP_ROOT_USER_ACTION="ignore"
ARG PIP_NO_COMPILE="true"
ARG PIP_DISABLE_PIP_VERSION_CHECK="true"

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    --mount=source=fc2-live-dl/requirements.txt,target=requirements.txt \
    pip3.11 install -r requirements.txt

# Ensure the cache is not reused when installing fc2-live-dl
ARG RELEASE

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    --mount=source=fc2-live-dl,target=.,rw \
    pip3.11 install . && \
    # Cleanup
    find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ;

########################################
# Final stage
########################################
FROM base AS final

ARG UID

# ffmpeg
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /ffmpeg /usr/bin/
# COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /ffprobe /usr/bin/

# dumb-init
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /dumb-init /usr/bin/

# Copy licenses (OpenShift Policy)
COPY --link --chown=$UID:0 --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chown=$UID:0 --chmod=775 fc2-live-dl/LICENSE /licenses/fc2-live-dl.LICENSE

# Copy dist and support arbitrary user ids (OpenShift best practice)
COPY --link --chown=$UID:0 --chmod=775 --from=build /root/.local /home/$UID/.local

ENV PATH="/home/$UID/.local/bin:$PATH"
ENV PYTHONPATH "/home/$UID/.local/lib/python3.11/site-packages:${PYTHONPATH}"

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh /bin/bash

WORKDIR /recordings

VOLUME [ "/recordings" ]

USER $UID

STOPSIGNAL SIGINT

# Use dumb-init as PID 1 to handle signals properly
ENTRYPOINT [ "dumb-init", "--", "fc2-live-dl" ]
CMD [ "-h" ]

ARG VERSION
ARG RELEASE
LABEL name="jim60105/docker-fc2-live-dl" \
    # Authors for fc2-live-dl
    vendor="HoloArchivists" \
    # Maintainer for this docker image
    maintainer="jim60105" \
    # Dockerfile source repository
    url="https://github.com/jim60105/docker-fc2-live-dl" \
    version=${VERSION} \
    # This should be a number, incremented with each change
    release=${RELEASE} \
    io.k8s.display-name="fc2-live-dl" \
    summary="fc2-live-dl: Tool to download FC2 live streams. autofc2: Monitor multiple channels at the same time, and automatically start downloading when any of them goes online." \
    description="For more information about this tool, please visit the following website: https://github.com/HoloArchivists/fc2-live-dl"
