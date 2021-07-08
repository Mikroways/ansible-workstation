FROM docker:stable-dind
RUN apk add --no-cache \
      python3 python3-dev py3-pip py3-virtualenv gcc git curl build-base \
      autoconf automake py3-cryptography linux-headers \
      musl-dev libffi-dev openssl-dev openssh rust \
    && python3 -m venv /opt/venv \
    && source /opt/venv/bin/activate \
    && pip install -U pip \
    && CRYPTOGRAPHY_DONT_BUILD_RUST=1 pip install \
      ansible==4.1.0 molecule[lint,docker]
ENV PY_COLORS="1"
