
FROM postgres:12.3

ENV PLV8_VERSION=2.3.8
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
    postgresql-server-dev-$PG_MAJOR"

ENV untimeDependencies="libc++1 \
    libtinfo5 \
    libc++abi1"

RUN apt-get update 
RUN apt-get install -y --no-install-recommends ${buildDependencies} ${untimeDependencies}
RUN mkdir -p /tmp/build 
RUN curl -o /tmp/build/v${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz" 
RUN tar -xzf /tmp/build/v${PLV8_VERSION}.tar.gz -C /tmp/build/ 
RUN cd /tmp/build/plv8-${PLV8_VERSION} && make 
RUN strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so 
RUN rm -rf /root/.vpython_cipd_cache /root/.vpython-root 
RUN apt-get clean 
RUN apt-get remove -y ${buildDependencies} 
RUN apt-get autoremove -y 
RUN rm -rf /tmp/build /var/lib/apt/lists/*
