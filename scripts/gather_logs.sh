#!/usr/bin/env bash

work_dir="$(cd "$(dirname "$0")" ; pwd -P)/../"
source $work_dir/docker-swarm.cfg

# default port for SSH is 22
if [ -z $port ];
then port=22
fi

ssh -Tq -p $port $user@$manager <<-'ENDSSH'
    rm -rf ~/logs.zip
    cd ~
    zip -r -o ~/logs.zip logs
ENDSSH

scp $user@$manager:/users/$user/logs.zip $output_dir/logs.zip