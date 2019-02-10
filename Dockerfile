ARG ALPINE_VERSION=3.7
FROM alpine:${ALPINE_VERSION}
ARG ALPINE_VERSION=3.7

RUN apk add --no-cache python3 py3-pip py3-yaml git curl findutils \
  && pip3 install \
    git+https://github.com/at-wat/rosdep.git@alpine-installer \
    git+https://github.com/alpine-ros/ros-abuild-docker.git \
    rosinstall_generator

ENV HOME="/root"

ENV APORTS_SLUG_UPSTREAM="seqsense/aports-ros-experimental"
ENV APORTS_SULG="seqsense/aports-ros-experimental"
ENV PACKAGE_LIST="package.list"
ENV ROS_DISTRO="kinetic"
ENV PARALLEL="4"
ENV GIT_EMAIL="noreply@seqsense.com"

COPY update-repo.sh /
COPY generate.sh /
COPY package.list /

ENTRYPOINT ["/update-repo.sh"]
