ARG ALPINE_VERSION=3.7
FROM alpine:${ALPINE_VERSION}
ARG ALPINE_VERSION=3.7

RUN apk add --no-cache python3 py3-pip py3-yaml git curl findutils \
  && pip3 install \
    git+https://github.com/alpine-ros/ros-abuild-docker.git \
    rosdep \
    rosinstall_generator

RUN rosdep init \
  && sed -i -e 's|ros/rosdistro/master|alpine-ros/rosdistro/alpine-custom-apk|' \
    /etc/ros/rosdep/sources.list.d/20-default.list

ENV HOME="/root"

ARG ROS_DISTRO="kinetic"

ENV APORTS_SLUG_UPSTREAM="seqsense/aports-ros-experimental"
ENV APORTS_SULG="seqsense/aports-ros-experimental"
ENV PACKAGE_LIST="package.list"
ENV ROS_DISTRO=${ROS_DISTRO}
ENV PARALLEL="4"
ENV GIT_EMAIL="noreply@seqsense.com"
ENV ROS_PYTHON_VERSION="2"

COPY update-repo.sh /
COPY package.list* /

ENTRYPOINT ["/update-repo.sh"]
