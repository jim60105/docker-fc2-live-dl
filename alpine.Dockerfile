# syntax=docker/dockerfile:1

FROM python:3.11-alpine as build

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install build dependencies
RUN apk add --no-cache build-base libffi-dev

WORKDIR /app

RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    --mount=source=fc2-live-dl/requirements.txt,target=requirements.txt \
    pip wheel --wheel-dir=/root/wheels -r requirements.txt

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    --mount=source=fc2-live-dl,target=.,rw \
    pip wheel --wheel-dir=/root/wheels .

# Uninstall inside venv
RUN pip3.11 uninstall -y setuptools pip && \
    pip3.11 uninstall -y setuptools pip

FROM python:3.11-alpine as final

RUN pip3.11 uninstall -y setuptools pip && \
    rm -rf /root/.cache/pip

# Copy venv
COPY --from=build /venv /venv
ENV PATH="/venv/bin:$PATH"

# Use dumb-init to handle signals
RUN apk add --no-cache dumb-init

# ffmpeg
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/local/bin/

RUN mkdir -p /recordings && chown 1001:1001 /recordings
VOLUME [ "/recordings" ]

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

USER 1001
WORKDIR /recordings

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "/venv/bin/fc2-live-dl" ]