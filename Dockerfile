
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

RUN apt-get update 
RUN apt-get install -y --no-install-recommends ${buildDependencies} ${untimeDependencies}
RUN mkdir -p /tmp/build 

# pg_repackのインストール
RUN git clone https://github.com/reorg/pg_repack.git;
RUN cd pg_repack; make; make install;

# plv8インストール
RUN curl -o /tmp/build/v${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz" 
RUN tar -xzf /tmp/build/v${PLV8_VERSION}.tar.gz -C /tmp/build/ 
RUN cd /tmp/build/plv8-${PLV8_VERSION} && make && make install
RUN strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so 
RUN rm -rf /root/.vpython_cipd_cache /root/.vpython-root 
RUN apt-get clean 
RUN apt-get remove -y ${buildDependencies} 
RUN apt-get autoremove -y 
RUN rm -rf /tmp/build /var/lib/apt/lists/*
