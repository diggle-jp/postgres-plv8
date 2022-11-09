
FROM postgres:13.4

ENV PLV8_VERSION=2.3.15
ENV buildDependencies="build-essential \
    ca-certificates \
    curl \
    git-core \
    python \
    python3 \
    gpp \
    cpp \
    pkg-config \
    apt-transport-https \
    cmake \
    libc++-dev \
    libc++abi-dev \
    libreadline-dev \
    zlib1g-dev \
    postgresql-server-dev-$PG_MAJOR"

ENV untimeDependencies="libc++1 \
    libtinfo5 \
    libc++abi1"

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${buildDependencies} ${untimeDependencies} && \
    mkdir -p /tmp/build; \
    # pg_repackのインストール
    git clone https://github.com/reorg/pg_repack.git; \
    cd pg_repack; git checkout ver_1.4.6; make; make install; \
    # plv8インストール
    curl -o /tmp/build/v${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz"; \
    tar -xzf /tmp/build/v${PLV8_VERSION}.tar.gz -C /tmp/build/; \
    cd /tmp/build/plv8-${PLV8_VERSION} && make && make install; \
    strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so; \
    rm -rf /root/.vpython_cipd_cache /root/.vpython-root; \
    apt-get clean; \
    apt-get remove -y ${buildDependencies}; \
    apt-get autoremove -y; \
    rm -rf /tmp/build /var/lib/apt/lists/*;
