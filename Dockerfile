# Install the application dependencies in a full UBI Node docker image
FROM registry.redhat.io/ubi9/nodejs-20 AS builder

ARG TARGETPLATFORM
ARG N8N_VERSION

RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

RUN npm install n8n@${N8N_VERSION}

# Setup the Task Runner Launcher
ARG LAUNCHER_VERSION=0.3.0-rc
COPY n8n-task-runners.json /opt/app-root/src/n8n-task-runners.json
RUN \
  if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCH_NAME="amd64"; \
  elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCH_NAME="arm64"; \
  else echo "Nepodporovaná platforma: $TARGETPLATFORM" && exit 1; fi; \
  echo "Architektura: $ARCH_NAME" && \
  mkdir /opt/app-root/src/launcher-temp && \
  cd /opt/app-root/src/launcher-temp && \
  curl -L https://github.com/n8n-io/task-runner-launcher/releases/download/${LAUNCHER_VERSION}/task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz -o task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz && \
  curl -L https://github.com/n8n-io/task-runner-launcher/releases/download/${LAUNCHER_VERSION}/task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz.sha256 -o task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz.sha256 && \
  echo "$(cat task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz.sha256) task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz" > checksum.sha256 && \
  sha256sum -c checksum.sha256 && \
  mkdir bin && \
  tar xvf task-runner-launcher-${LAUNCHER_VERSION}-linux-${ARCH_NAME}.tar.gz --directory=./bin




# Copy the dependencies into a minimal Node.js image
FROM registry.redhat.io/ubi9/nodejs-20-minimal

ARG N8N_VERSION

RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

LABEL org.opencontainers.image.title="n8n"
LABEL org.opencontainers.image.description="Workflow Automation Tool"
LABEL org.opencontainers.image.source="https://github.com/n8n-io/n8n"
LABEL org.opencontainers.image.url="https://n8n.io"
LABEL org.opencontainers.image.version=${N8N_VERSION}

COPY --from=builder /opt/app-root/src/node_modules /opt/app-root/src/node_modules
COPY --from=builder /opt/app-root/src/package.json /opt/app-root/src/package.json

USER root
RUN microdnf install git
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY n8n-task-runners.json /etc/n8n-task-runners.json
COPY --from=builder /opt/app-root/src/launcher-temp/bin/task-runner-launcher /usr/local/bin/task-runner-launcher

USER 1001

EXPOSE 5678
VOLUME /opt/app-root/src/ca-trust
VOLUME /opt/app-root/src/.n8n
VOLUME /opt/app-root/src/.cache

ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

ENTRYPOINT ["/docker-entrypoint.sh"]
