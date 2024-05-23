FROM postgres:13.8 AS base

# Mac などの arm 環境でビルドすると、次のエラーが発生する `clang++: error: unknown argument: '-ftrivial-auto-var-init=pattern'`
# これは PLV8 のビルド時に発生するエラーで arm 環境で v3.0.0 の場合に起きる https://github.com/plv8/plv8/issues/444
# そのため、PLV8 のバージョンが 3.0.0 のあいだは、docker build を実行する環境が x86_64 でなければならない。
# Mac などの arm 環境からビルドするときには docker build --platform linux/amd64 のように、platform を指定すること。
#
# GitHub のコメントより、この事象は PLV8 のバージョンが v3.1 などでは解消していると思われる。
# v3.0.0 以降で問題の解消を確認した際には、このコメントを削除する。

FROM base AS build-pg_repack
ENV PG_REPACK_VERSION 1.4.6
ENV buildDependencies "build-essential \
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
ENV PLV8_VERSION 3.0.0
ENV buildDependencies "build-essential \
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
    curl -o /tmp/build/v${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz"; \
    tar -xzf /tmp/build/v${PLV8_VERSION}.tar.gz -C /tmp/build/; \
    cd /tmp/build/plv8-${PLV8_VERSION} && make && make install; \
    strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so

FROM base AS finalize

COPY --from=build-pg_repack /usr/lib/postgresql/ /usr/lib/postgresql/
COPY --from=build-pg_repack /usr/share/postgresql/ /usr/share/postgresql/

COPY --from=build-plv8 /usr/lib/postgresql/ /usr/lib/postgresql/
COPY --from=build-plv8 /usr/share/postgresql/ /usr/share/postgresql/

ENV runtimeDependencies "libc++1"
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${runtimeDependencies} && \
    apt-get clean && \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*;
