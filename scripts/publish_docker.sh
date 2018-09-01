#!/usr/bin/env bash

work_dir="$(cd "$(dirname "$0")" ; pwd -P)/../"
source "$work_dir/docker-swarm.cfg"

token="undefined"

all() {
    setup
    take_down_swarm
    swarm_token=$(init_manager)
    join_workers $swarm_token
    compile
    publish
}

take_down_swarm() {
    echo "Taking down possible existing swarm"
    ssh -Tq -p $port $user@$manager 'docker swarm leave --force || exit 0;'
    for i in "${workers[@]}"
    do
        ssh -Tq -p $port $user@$i 'docker swarm leave --force || exit 0;'
    done
}

setup_instance() {
    echo "Setting up instance $1"

    ssh -T -p $port $user@$1 <<-'ENDSSH'
        mkdir -p ~/src && mkdir -p ~/logs

    if ! [ -x "$(command -v docker)" ]; then
        # Update the apt package index
        sudo apt-get update

        # Install packages to allow apt to use a repository over HTTPS
        sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

        # Add Docker’s official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        # Use the following command to set up the stable repository
        sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

        # Update the apt package index
        sudo apt-get update

        # Install the latest version of Docker CE
        sudo apt-get install docker-ce -y

        # Create the docker group.
        sudo groupadd docker

        # Add your user to the docker group.
        sudo usermod -aG docker $USER
    else
        echo "Docker already installed on $1"
    fi
ENDSSH
}

setup() {
    setup_instance $manager
    for i in "${workers[@]}"
    do
        setup_instance $i
    done
}

init_manager() {
    `ssh -T -p $port $user@$manager "sudo hostname cluster0"` 2> /dev/null
    `ssh -T -p $port $user@$manager "docker swarm init --advertise-addr $manager"` 2> /dev/null
    # currently we are pushing jar file to all of the workers and building image locally on all of the workers
    # in future we should use docker registry service to create image on manager and use it as reference in worker nodes
    #ssh $user@$manager "docker service create --name registry --publish published=5000,target=5000 registry:2"
    token=`ssh -T -p $port $user@$manager 'docker swarm join-token worker -q'`
    echo $token #using this a global variable (DONT REMOVE)
}

join_workers() {
    count=0
    for i in "${workers[@]}"
    do
        count=$((count+1))
        echo "processing worker $i with hostname cluster$count"
        ssh -T -p $port $user@$i "docker swarm join --token $1 $manager:2377 && sudo hostname cluster$count"
    done
}

build_container() {
    ssh -p $port $user@$1 <<-'ENDSSH'
    docker rmi adaptivecep -f
    docker rmi $(docker images -q --filter "dangling=true") -f
    cd ~/src && docker build -t adaptivecep .
    rm -r ~/logs
    mkdir ~/logs
ENDSSH
}

publish() {
    if [ ! -z $registry_user ];
    then
        printf "\nLogin required to push images for localhost\n"
        docker login
        printf "\nLogin required to pull images for docker manager\n"
        ssh -t -p $port $user@$manager 'docker login'; # interactive shell to input registry credentials
        mkdir $work_dir/dockerbuild
        printf "\nBuilding image\n"
        cp $work_dir/target/scala-2.12/adaptivecep_2.12-0.0.1-SNAPSHOT-one-jar.jar $work_dir/dockerbuild
        cp $work_dir/Dockerfile $work_dir/dockerbuild
        cp $work_dir/docker-entrypoint.sh $work_dir/dockerbuild
        cp $work_dir/docker-compose.yml $work_dir/dockerbuild
        docker build -t adaptivecep $work_dir/dockerbuild
        docker tag adaptivecep $registry_user/$registry_image
        printf "\nPushing image to registry\n"
        docker push $registry_user/$registry_image
        printf "\nRemoving old docker stack\n"
        ssh -T -p $port $user@$manager "docker rmi $registry_user/$registry_image -f"
        printf "\nPulling image from registry\n"
        ssh -T -p $port $user@$manager "docker pull $registry_user/$registry_image && docker tag $registry_user/$registry_image adaptivecep"
        rm -rf $work_dir/dockerbuild
    else
        echo "Building container on master"
        copy $manager
        build_container $manager

        echo "Building container on workers"
        for i in "${workers[@]}"
        do
            copy $i;
            build_container $i;
        done
    fi

    # stop running services
    ssh -p $port $user@$manager <<-'ENDSSH'
    if [[ $(docker service ls -q) ]]; then # only stop services if there are any running
        docker service rm $(docker service ls -q)
    fi
ENDSSH


    printf "\nBooting up new stack\n"

    ssh -p $port $user@$manager 'mkdir -p ~/logs && rm -f ~/logs/** && mkdir -p ~/src && sudo hostname cluster0';
    scp -P $port $work_dir/docker-stack.yml $user@$manager:~/src/docker-stack.yml
    ssh -p $port $user@$manager 'cd ~/src && docker stack deploy --prune --with-registry-auth -c docker-stack.yml transitiveCEP';
}


copy () {
    ssh -T -p $port $user@$1 'rm -rf ~/src'
    ssh -T -p $port $user@$1 'mkdir ~/src'
    scp -P $port $work_dir/target/scala-2.12/adaptivecep_2.12-0.0.1-SNAPSHOT-one-jar.jar $user@$1:~/src/adaptivecep_2.12-0.0.1-SNAPSHOT-one-jar.jar
    scp -P $port $work_dir/Dockerfile $user@$1:~/src/Dockerfile
    scp -P $port $work_dir/docker-compose.yml $user@$1:~/src/docker-compose.yml
    scp -P $port $work_dir/docker-entrypoint.sh $user@$1:~/src/docker-entrypoint.sh
}

compile () {
   cd $work_dir && sbt one-jar
}

# Set the port variable default to 22 if not set
if [ -z $port ];
then port=22
fi

if [ $1 == "compile" ]; then compile
elif [ $1 == "publish" ]; then publish
elif [ $1 == "copy" ]; then copy
elif [ $1 == "setup" ]; then setup
elif [ $1 == "all" ]; then all
else echo "invalid/missing operation"
fi
