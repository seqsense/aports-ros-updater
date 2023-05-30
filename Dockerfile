ARG ALPINE_VERSION=3.14

# ========================================
FROM alpine:${ALPINE_VERSION} as gh-downloader

RUN wget https://github.com/cli/cli/releases/download/v2.29.0/gh_2.29.0_linux_amd64.tar.gz -O - \
    | tar xzfv - \
  && mv gh_* gh

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

# TODO: use `apk add --no-cache gh` after dropping Melodic
COPY --from=gh-downloader /gh/bin/gh /usr/local/bin/
RUN gh --version

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
