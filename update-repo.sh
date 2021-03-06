#!/bin/sh

set -e

dry_run='false'
while getopts d opt; do
  case ${opt} in
    "d" ) dry_run='true' ; echo '[dry-run]';;
  esac
done

# env vars:
#   APORTS_SLUG_UPSTREAM
#   APORTS_SULG
#   PACKAGE_LIST
#   ROS_DISTRO
#   PARALLEL
#   GIT_EMAIL

aports_slug_upstream=${APORTS_SLUG_UPSTREAM:-seqsense/aports-ros-experimental}
aports_slug=${APORTS_SLUG:-${aports_slug_upstream}}
ros_distro=${ROS_DISTRO:-kinetic}
package_list=$(
  if [ -f package.list.${ros_distro} ]; then
    cat package.list.${ros_distro}
    exit 0
  fi
  cat ${PACKAGE_LIST:-package.list}
)
ros_python_version=${ROS_PYTHON_VERSION:-2}
parallel=${PARALLEL:-4}
git_email=${GIT_EMAIL:-noreply@seqsense.com}

git_common_opt="-C aports"


aports_dir=aports/ros/${ros_distro}

case ${ros_python_version} in
  "2" ) ;;
  "3" ) ;;
  * ) echo "Unknown ROS_PYTHON_VERSION ${ros_python_version}" >&2; exit 1;;
esac


# Prepare aports repository

if [ -d aports ]; then
  git ${git_common_opt} pull upstream master
else
  git clone --depth=1 -o upstream \
    https://github.com/${aports_slug_upstream}.git aports
  git ${git_common_opt} remote add origin \
    https://github.com/${aports_slug}.git
  git ${git_common_opt} config user.name "Alpine ROS aports update bot"
  git ${git_common_opt} config user.email "${git_email}"
fi

mkdir -p ${aports_dir}


# Store rosdistro cache locally

wget -q \
  -O /rosdistro-cache.yaml.gz \
  http://repositories.ros.org/rosdistro_cache/${ros_distro}-cache.yaml.gz
wget -q \
  -O /distribution.yaml \
  https://raw.githubusercontent.com/ros/rosdistro/master/${ros_distro}/distribution.yaml
cat << EOF > /index.yaml
%YAML 1.1
# ROS index file
# see REP 143: http://ros.org/reps/rep-0143.html
---
distributions:
  ${ros_distro}:
    distribution: ["file:///distribution.yaml"]
    distribution_cache: "file:///rosdistro-cache.yaml.gz"
type: index
version: 3
EOF
echo "Using local copy of rosdistro"
cat /index.yaml
export ROSDISTRO_INDEX_URL=file:///index.yaml


# Generate all APKBUILDs

rosdep update

package_list_full=''
rosinstall_generator --deps --wet-only --flat ${package_list} --rosdistro ${ros_distro} \
  | grep 'local-name:' | while read line; do
  pkgname=$(echo $line | sed -e 's/.*:\s*//')
  if [ ! -z ${pkgname} ]; then
    aportname=ros-${ros_distro}-$(echo ${pkgname} | sed 's/_/-/g')
    mkdir -p ${aports_dir}/${aportname}
    echo $pkgname ${aports_dir}/${aportname}/APKBUILD
    echo $pkgname ${aports_dir}/${aportname}/APKBUILD >&2
  fi
done \
  | generate-rospkg-apkbuild-multi ${ros_distro}


# Commit changes and create PullRequest

files="$(git ${git_common_opt} diff --name-only \
  | sed 's/^/- /;s|/|\\/|g;s/$/\\n/g' | tr -d '\n')"

git ${git_common_opt} add ros
if git ${git_common_opt} diff --cached --exit-code; then
  echo "No update found"
else
  date=$(date +%Y%m%d-%H%M%S)
  git ${git_common_opt} checkout -b auto-update/${ros_distro}/${date}
  git ${git_common_opt} commit -m "${ros_distro}: automatic update on ${date}" \
    --author="Alpine ROS aports update bot <${git_email}>"

  pr_user=$(dirname ${aports_slug})
  pr_request_body=$(cat << EOF
{
  "title": "${ros_distro}: automatic update on ${date}",
  "body": "Updates found in rosdistro\\n${files}",
  "head": "${pr_user}:auto-update\/${ros_distro}\/${date}",
  "base": "master"
}
EOF
)
  echo ${pr_request_body}
  sleep 2

  if [ ${dry_run} == 'false' ]; then
    git ${git_common_opt} push origin auto-update/${ros_distro}/${date}
    sleep 2
    curl https://api.github.com/repos/${aports_slug_upstream}/pulls \
      -d "${pr_request_body}" -XPOST -n
  else
    echo 'Skipping PR'
  fi
fi
