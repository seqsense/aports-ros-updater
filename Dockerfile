ARG ALPINE_VERSION=3.14

# ========================================
FROM alpine:${ALPINE_VERSION} as gh-downloader

RUN apk update \
  && apk fetch --no-cache github-cli

# ========================================
FROM alpine:${ALPINE_VERSION}
ARG ALPINE_VERSION=3.14

RUN apk add --no-cache python3 py3-pip py3-yaml git curl findutils \
  && pip3 install \
    git+https://github.com/alpine-ros/ros-abuild-docker.git \
    rosdep \
    rosinstall_generator

RUN rosdep init \
  && sed -i -e 's|ros/rosdistro/master|alpine-ros/rosdistro/alpine-custom-apk|' \
    /etc/ros/rosdep/sources.list.d/20-default.list

COPY --from=gh-downloader github-cli*.apk .

RUN apk add github-cli*.apk \
  && rm -f github-cli*.apk

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
