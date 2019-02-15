# aports-ros-updater
rosdistro update checker for aports-ros-experimental

## How to register a new package to Alpine ROS

1. Bloom release and register the package to the ROS official rosdistro
2. Add a package name to [package.list](package.list) and open a PullRequest
3. After the PullRequest on aports-ros-updater is merged, generated APKBUILDs will be sent to [aports-ros-experimental](https://github.com/seqsense/aports-ros-experimental) as a PullRequest
4. Pass a test build of the PullRequest on aports-ros-experimental by adding missing dependencies, patches and/or NOCHECK file
5. Once the PullRequest on aports-ros-experimental is merged, aports-ros-updater will weekly check the update on the official rosdisto
