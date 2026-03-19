FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        iproute2 \
        libcap2-bin \
        procps \
        util-linux \
    && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]

