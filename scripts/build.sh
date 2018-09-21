#!/usr/bin/env bash
# Author: Manisha Luthra
# Modified by: Sebastian Hennig
# Description: Builds and creates the docker image of TCEP

work_dir="$(cd "$(dirname "$0")" ; pwd -P)/../"
source "$work_dir/docker-swarm.cfg"

printf "\nLogin required to push images for localhost\n"
docker login

printf "\nBuilding image\n"
docker build -t tcep $work_dir/dockerbuild
docker tag tcep $registry_user/$tcep_image
printf "\nPushing image to registry\n"
docker push $registry_user/$tcep_image

printf "\nBuilding GUI image\n"
cd $work_dir/gui
docker build -t tcep-gui .
docker tag tcep-gui $registry_user/$gui_image
docker push $registry_user/$gui_image
