#!/usr/bin/env bash

set -x


# Setting an install prefix environment variable
export INSTALL_PREFIX=/usr/local
# Adjusting PATH for running gvmd
export PATH=$PATH:$INSTALL_PREFIX/sbin
# Choosing a source directory
export SOURCE_DIR=$HOME/source
mkdir -p $SOURCE_DIR
# Choosing a build directory
export BUILD_DIR=$HOME/build
mkdir -p $BUILD_DIR
# Choosing a temporary install directory
export INSTALL_DIR=$HOME/install
mkdir -p $INSTALL_DIR

# Setting a GVM version as environment variable
export GVM_VERSION=22.4.1



#####################################################
# GVMD                                              #
#####################################################

# Setting the gvmd version to use
export GVMD_VERSION=22.4.2

# Required dependencies for gvmd
sudo apt install -y \
  libglib2.0-dev \
  libgnutls28-dev \
  libpq-dev \
  postgresql-server-dev-13 \
  libical-dev \
  xsltproc \
  rsync \
  libbsd-dev \
  libgpgme-dev

# Optional dependencies for gvmd
sudo apt install -y --no-install-recommends \
  texlive-latex-extra \
  texlive-fonts-recommended \
  xmlstarlet \
  zip \
  rpm \
  fakeroot \
  dpkg \
  nsis \
  gnupg \
  gpgsm \
  wget \
  sshpass \
  openssh-client \
  socat \
  snmp \
  python3 \
  smbclient \
  python3-lxml \
  gnutls-bin \
  xml-twig-tools

# Downloading the gvmd sources
curl -f -L https://github.com/greenbone/gvmd/archive/refs/tags/v$GVMD_VERSION.tar.gz -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gvmd/releases/download/v$GVMD_VERSION/gvmd-$GVMD_VERSION.tar.gz.asc -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc

# Verifying the source file
gpg --verify $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz

# Building gvmd
mkdir -p $BUILD_DIR/gvmd && cd $BUILD_DIR/gvmd
cmake $SOURCE_DIR/gvmd-$GVMD_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLOCALSTATEDIR=/var \
  -DSYSCONFDIR=/etc \
  -DGVM_DATA_DIR=/var \
  -DGVMD_RUN_DIR=/run/gvmd \
  -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
  -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
  -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
  -DLOGROTATE_DIR=/etc/logrotate.d
make -j$(nproc)

# Installing gvmd
mkdir -p $INSTALL_DIR/gvmd
make DESTDIR=$INSTALL_DIR/gvmd install
sudo cp -rv $INSTALL_DIR/gvmd/* /
sudo cp -rv $INSTALL_DIR/gvmd/lib/* /lib/

