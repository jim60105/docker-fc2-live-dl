# syntax=docker/dockerfile:1

########################################
# Build stage
########################################
FROM python:3.12-bookworm as build

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
    pip install -U --force-reinstall pip setuptools wheel && \
    pip install -r requirements.txt

# Ensure the cache is not reused when installing fc2-live-dl
ARG RELEASE

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    --mount=source=fc2-live-dl,target=.,rw \
    pip install . && \
    # Cleanup
    find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ; \
    # Make an empty directory for final stage
    mkdir -p /newdir

########################################
# Final stage
# Distroless image use monty(1000) for non-root user
########################################
FROM al3xos/python-distroless:3.12-debian12 as final

# Create directories with correct permissions
COPY --link --chown=1000:0 --chmod=775 --from=build /newdir /recordings
COPY --link --chown=1000:0 --chmod=775 --from=build /newdir /licenses

# ffmpeg
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.1 /ffmpeg /usr/bin/
# COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.1 /ffprobe /usr/bin/

# dumb-init
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.1 /dumb-init /usr/bin/

# Copy licenses (OpenShift Policy)
COPY --link --chown=1000:0 --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chown=1000:0 --chmod=775 fc2-live-dl/LICENSE /licenses/fc2-live-dl.LICENSE

# Copy dist and support arbitrary user ids (OpenShift best practice)
COPY --link --chown=1000:0 --chmod=775 --from=build /root/.local /home/monty/.local

ENV PATH="/home/monty/.local/bin:$PATH"
ENV PYTHONPATH="/home/monty/.local/lib/python3.12/site-packages:${PYTHONPATH}"

WORKDIR /recordings

VOLUME [ "/recordings" ]

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
