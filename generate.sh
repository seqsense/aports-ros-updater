#!/bin/sh

generate-rospkg-apkbuild $1 $2 | tee aports/ros/$1/$2/APKBUILD
