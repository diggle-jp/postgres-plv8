FROM postgres:13.13-bullseye AS base

FROM base AS build-pg_repack
ENV PG_REPACK_VERSION=1.4.7
ENV buildDependencies="build-essential \
    ca-certificates \
    clang \
    git \
    libreadline-dev \
    llvm \
    postgresql-server-dev-$PG_MAJOR \
    zlib1g-dev"
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${buildDependencies} && \
    git clone https://github.com/reorg/pg_repack.git; \
    cd pg_repack; git checkout ver_${PG_REPACK_VERSION}; make; make install;

FROM base AS build-plv8
ENV PLV8_VERSION=3.1.8
ENV buildDependencies="build-essential \
    ca-certificates \
    clang \
    curl \
    git \
    libc++-dev \
    libc++abi-dev \
    libstdc++-10-dev \
    libtinfo5 \
    llvm \
    ninja-build \
    pkg-config \
    postgresql-server-dev-$PG_MAJOR \
    python \
    wget"
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${buildDependencies} && \
    mkdir -p /tmp/build; \
    curl -o /tmp/build/v${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/refs/tags/v${PLV8_VERSION}.tar.gz"; \
    tar -xzf /tmp/build/v${PLV8_VERSION}.tar.gz -C /tmp/build/; \
    cd /tmp/build/plv8-${PLV8_VERSION} && make && make install; \
    strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so

FROM base AS finalize

COPY --from=build-pg_repack /usr/lib/postgresql/ /usr/lib/postgresql/
COPY --from=build-pg_repack /usr/share/postgresql/ /usr/share/postgresql/

COPY --from=build-plv8 /usr/lib/postgresql/ /usr/lib/postgresql/
COPY --from=build-plv8 /usr/share/postgresql/ /usr/share/postgresql/

ENV runtimeDependencies="libc++1"
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${runtimeDependencies} && \
    apt-get clean && \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*;
