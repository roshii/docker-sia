FROM debian:stretch-slim

ENV SIA_VERSION 1.2.2
ENV SIA_PACKAGE Sia-v$SIA_VERSION-linux-amd64
ENV SIA_ZIP ${SIA_PACKAGE}.zip
# Choose a binary release of Sia.
ENV SIA_RELEASE https://github.com/NebulousLabs/Sia/releases/download/v$SIA_VERSION/$SIA_ZIP
# Choose the directory within the container where Docker will place Sia.
ENV SIA_DIR /opt/$SIA_PACKAGE

RUN set -ex \
  && apt-get update -qq \
  && apt-get install -qq --no-install-recommends ca-certificates socat wget unzip \
  && rm -rf /var/lib/apt/lists/*

# Download and install Sia.
RUN set -ex \
  && wget -q $SIA_RELEASE \
  && unzip $SIA_ZIP -d /opt

# Make the Sia ports available to the Docker container's host.
EXPOSE 8000 9981 9982

# Configure the Sia daemon to run when the container starts.
# Forward 8000 to localhost:9980 so it's accessible outside the container.
# Specify the Sia directory as /mnt/sia so that you can view these files outside
# of Docker.
WORKDIR $SIA_DIR
ENTRYPOINT socat tcp-listen:8000,reuseaddr,fork tcp:localhost:9980 & ./siad --modules gctwhr --sia-directory /mnt/sia
