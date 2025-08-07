FROM postgres:13.21-bullseye AS base

FROM base AS build-pg_repack
ENV PG_REPACK_VERSION=1.5.1
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
    git clone --branch ver_${PG_REPACK_VERSION} --single-branch --depth 1 https://github.com/reorg/pg_repack.git && \
    cd pg_repack && make && make install

FROM base AS build-plv8
ENV PLV8_VERSION=3.1.10
ENV buildDependencies="build-essential \
    binutils \
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
    python3 \
    wget"
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${buildDependencies} && \
    git clone --branch v${PLV8_VERSION} --single-branch --depth 1 https://github.com/plv8/plv8.git && \
    cd plv8 && make && make install && \
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
