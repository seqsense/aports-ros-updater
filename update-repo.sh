#!/bin/sh

set -e

# env vars:
#   APORTS_SLUG_UPSTREAM
#   APORTS_SULG
#   PACKAGE_LIST
#   ROS_DISTRO
#   PARALLEL
#   GIT_EMAIL

aports_slug_upstream=${APORTS_SLUG_UPSTREAM:-seqsense/aports-ros-experimental}
aports_slug=${APORTS_SLUG:-${aports_slug_upstream}}
package_list=$(cat ${PACKAGE_LIST:-package.list})
ros_distro=${ROS_DISTRO:-kinetic}
parallel=${PARALLEL:-4}
git_email=${GIT_EMAIL:-noreply@seqsense.com}

git_common_opt="-C aports"


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

mkdir -p aports/ros/${ros_distro}


# Generate all APKBUILDs

package_list_full=''
rosinstall_generator --deps --wet-only --flat ${package_list} --rosdistro ${ros_distro} \
  | grep 'local-name:' | while read line; do
  pkgname=$(echo $line | sed -e 's/.*:\s*//')
  if [ ! -z $pkgname ]; then
    mkdir -p aports/ros/${ros_distro}/$pkgname
    echo $pkgname
  fi
done \
  | xargs -t -n1 -P${parallel} ./generate.sh ${ros_distro}


# Commit changes and create PullRequest

git ${git_common_opt} add ros
if git ${git_common_opt} diff --cached --exit-code; then
  echo "No update found"
else
  date=$(date +%Y%m%d-%H%M%S)
  git ${git_common_opt} checkout -b auto-update/${date}
  git ${git_common_opt} commit -m "Automatic update on ${date}" \
    --author="Alpine ROS aports update bot <${git_email}>"

  pr_user=$(dirname ${aports_slug})
  pr_request_body=$(cat << EOF
{
  "title": "Automatic update on ${date}",
  "body": "Updates found in rosdistro",
  "head": "${pr_user}:auto-update\/${date}",
  "base": "master"
}
EOF
)
  echo ${pr_request_body}
  sleep 2

  git ${git_common_opt} push origin auto-update/${date}
  sleep 2
  curl https://api.github.com/repos/${aports_slug_upstream}/pulls \
    -d "${pr_request_body}" -XPOST -n
fi
