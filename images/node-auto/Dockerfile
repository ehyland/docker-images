ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION}-slim

# runtime deps
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  jq \
  curl \
  wget \
  gnupg \
  unzip \
  dirmngr \
  xz-utils \
  libatomic1  \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# runtime user
RUN groupadd --gid 1000 app \
  && useradd --uid 1000 --gid app --shell /bin/bash --create-home app \
  && mkdir /app

# install fnm
ENV PATH="/fnm/bin:$PATH"
ENV PATH="/fnm/aliases/default/bin:$PATH" \
  FNM_DIR="/fnm"
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- \
  --skip-shell \
  --install-dir /fnm/bin

# fix perms
RUN chown -R app:app /fnm /app /home/app

# script for setup for node install
COPY --chown=root:root ./docker /docker

# set timezone (copy this to override)
ENV TZ=Australia/Melbourne
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
  && echo "$TZ" > /etc/timezone

WORKDIR /app
USER app

# setup pnpm for build caching
RUN \
  echo "store-dir=/home/app/.pnpm/store-dir" >> /home/app/.npmrc && \
  echo "cache-dir=/home/app/.pnpm/cache-dir" >> /home/app/.npmrc && \
  echo "state-dir=/home/app/.pnpm/state-dir" >> /home/app/.npmrc && \
  mkdir -p /home/app/.pnpm

ENV PNPM_HOME=/app/.pnpm-store
