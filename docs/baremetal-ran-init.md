# Setup an Ubuntu container

To compile Openairinterface5G code, when the container is up run these comamnds

```
apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    --no-install-recommends \
    apt-utils \
    software-properties-common \
    build-essential \
    net-tools pkg-config make screen git wget curl tar vim \
    ca-certificates llvm
```

```
apt-get install -y --no-install-recommends \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncurses5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8
```

```
set -ex \
    && curl https://pyenv.run | bash \
    && pyenv update \
    && pyenv install 3.6 \
    && pyenv global 3.6 \
    && pyenv rehash
```

Check whether the desired python version is installed:
```
python -V
```
