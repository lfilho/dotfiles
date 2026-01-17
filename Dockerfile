FROM ubuntu:22.04
LABEL maintainer="Luiz Filho <lfilho@gmail.com>"

ENV TERM=xterm-256color

# Bootstrapping packages needed for installation
RUN \
  apt-get update && \
  apt-get install -yqq \
    locales \
    lsb-release \
    software-properties-common && \
  apt-get clean

# Set locale to UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
  /usr/sbin/update-locale LANG=$LANG

# Install dependencies
# Universe repository is enabled by default in Ubuntu 22.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get -yqq install \
    autoconf \
    build-essential \
    curl \
    fontconfig \
    git \
    neovim \
    python3 \
    python3-pip \
    python3-dev \
    sudo \
    tmux \
    unzip \
    vim \
    wget \
    zsh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user for Homebrew installation
RUN useradd -m -s /bin/bash yadr && \
  echo "yadr ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install dotfiles as non-root user
USER yadr
WORKDIR /home/yadr
COPY --chown=yadr:yadr . /home/yadr/.yadr

# Accept CI build argument and set as environment variable
ARG CI=false
ENV CI=${CI}

RUN cd /home/yadr/.yadr && ./install.sh

# Run a zsh session
CMD [ "/bin/zsh" ]
