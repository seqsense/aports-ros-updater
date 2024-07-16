# syntax=docker/dockerfile:1

ARG ALPINE_VERSION=3.17

# ========================================
FROM alpine:${ALPINE_VERSION}
ARG ALPINE_VERSION=3.17

RUN echo "http://alpine-ros.seqsense.org/v${ALPINE_VERSION}/backports" >> /etc/apk/repositories
COPY <<EOF /etc/apk/keys/builder@alpine-ros-experimental.rsa.pub
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnSO+a+rIaTorOowj3c8e
5St89puiGJ54QmOW9faDsTcIWhycl4bM5lftp8IdcpKadcnaihwLtMLeaHNJvMIP
XrgEEoaPzEuvLf6kF4IN8HJoFGDhmuW4lTuJNfsOIDWtLBH0EN+3lPuCPmNkULeo
iS3Sdjz10eB26TYiM9pbMQnm7zPnDSYSLm9aCy+gumcoyCt1K1OY3A9E3EayYdk1
9nk9IQKA3vgdPGCEh+kjAjnmVxwV72rDdEwie0RkIyJ/al3onRLAfN4+FGkX2CFb
a17OJ4wWWaPvOq8PshcTZ2P3Me8kTCWr/fczjzq+8hB0MNEqfuENoSyZhmCypEuy
ewIDAQAB
-----END PUBLIC KEY-----
EOF

RUN apk add --no-cache \
    curl \
    findutils \
    git \
    gh \
    py3-pip \
    py3-rosdep \
    py3-rosinstall-generator \
    py3-yaml \
    python3 \
  && pip3 install $([ "${ALPINE_VERSION}" != '3.17' ] && echo -n '--break-system-packages') \
    git+https://github.com/alpine-ros/ros-abuild-docker.git

RUN rosdep init \
  && sed -i -e 's|ros/rosdistro/master|alpine-ros/rosdistro/alpine-custom-apk|' \
    /etc/ros/rosdep/sources.list.d/20-default.list

ENV HOME="/root"

ARG ROS_DISTRO="noetic"

ENV \
  ALPINE_VERSION=${ALPINE_VERSION} \
  APORTS_SLUG_UPSTREAM="seqsense/aports-ros-experimental" \
  APORTS_SULG="seqsense/aports-ros-experimental" \
  GIT_EMAIL="noreply@seqsense.com" \
  PARALLEL="4" \
  ROS_DISTRO=${ROS_DISTRO} \
  ROS_PYTHON_VERSION="3"

COPY update-repo.sh /
COPY package.list* /

ENTRYPOINT ["/update-repo.sh"]
