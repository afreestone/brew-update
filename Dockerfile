ARG version=20.04
# 22.04 removes Libssl1.1 in favour of Libssl3, but Ruby 2.6.0 requires 1.1
# shellcheck disable=SC2154
FROM ubuntu:"${version}"
ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common gnupg-agent \
  && add-apt-repository -y ppa:git-core/ppa \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    file \
    fonts-dejavu-core \
    g++ \
    gawk \
    git \
    less \
    libz-dev \
    locales \
    make \
    netbase \
    openssh-client \
    patch \
    sudo \
    uuid-runtime \
    tzdata \
    libssl1.1 \
  && apt remove --purge -y software-properties-common \
  && apt autoremove --purge -y \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -f UTF-8 en_US.UTF-8 \
  && useradd -m -s /bin/bash linuxbrew \
  && echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers \
  && su - linuxbrew -c 'mkdir ~/.linuxbrew'

USER linuxbrew
RUN git clone --depth 1 https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
WORKDIR /home/linuxbrew

RUN mkdir -p \
     .linuxbrew/bin \
     .linuxbrew/etc \
     .linuxbrew/include \
     .linuxbrew/lib \
     .linuxbrew/opt \
     .linuxbrew/sbin \
     .linuxbrew/share \
     .linuxbrew/var/homebrew/linked \
     .linuxbrew/Cellar \
  && ln -s ../Homebrew/bin/brew .linuxbrew/bin/brew \
  && git -C .linuxbrew/Homebrew remote set-url origin https://github.com/Homebrew/brew \
  && git -C .linuxbrew/Homebrew fetch origin \
  && HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_AUTO_UPDATE=1 brew tap homebrew/core \
  && brew install-bundler-gems \
  && brew cleanup \
  && { git -C .linuxbrew/Homebrew config --unset gc.auto; true; } \
  && { git -C .linuxbrew/Homebrew config --unset homebrew.devcmdrun; true; } \
  && rm -rf .cache

RUN brew install rbenv ruby-build
RUN eval "$(rbenv init - bash)"
RUN rbenv install 2.6.0
RUN rbenv global 2.6.0
RUN gem install bundler -v '1.17.3'