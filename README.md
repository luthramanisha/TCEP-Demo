# TCEP-Demo

## Running on GENI

GENI provides a large-scale experiment infrastructure where users can obtain computing instances throughout the United States to perform network experiments.
TCEP includes useful scripts to enable easier simulations on GENI which are described below.

```
cd scripts/
```

First, a so called RSpec XML file is needed in order to get a GENI cluster up and running. To automatically generate a cluster with a specified number of nodes you can execute the following command:

```
python generate_geni_rspec.py {number-of-nodes} {out-directory}
```

This will generate the rspec.xml file with the at "out-directory" with the specified number of nodes. Furthermore, this also generate the Docker swarm file with the correct amount of empty apps running on the GENI hosts.

After you deployed the RSpec on GENI, you can download a Manifest XML file which contains information of the hosts that GENI deployed. This is useful because GENI automatically generates IP addresses for the hosts and if you created a cluster with a high amount of nodes the search for this IP addresses can be a heavy overhead.
After downloading the manifest file you can run the following command to extract the IP addresses out of it and print out the config that can be put into the "docker-swarm.cfg" file:

```
python manifest_to_config.py {manifest-path}
```

This will convert the manifest and will print out the IP addresses of the started hosts in the config format for the docker deploy script.
You should see an output like this

```
manager=xx.xx.xx.xx
workers=("xx.xx.xx.xx" "xx.xx.xx.xx")
```

Now the hosts are successfully deployed on GENI and the project is ready to be setup on the hosts. To setup the GENI instances to be able to run docker, run the following command

```
./publish_docker.sh setup
```

Note that you maybe have to enter `yes` in the console multiple times to allow SSH connections to the hosts

After the instances are all setup, you can go forward and finally run the cluster on the hosts by executing the following command

```
./publish_docker.sh all
```

### Additional Resources:

[1] M. Luthra, B. Koldehofe, R. Arif, P. Weisenburger, G. Salvaneschi, TCEP: Adapting to Dynamic User Environments by Enabling Transitions between Operator Placement Mechanisms. In the Proceedings of 12th ACM International Conference on Distributed and Event-based Systems (DEBS) 2018
https://dl.acm.org/citation.cfm?id=3210292

[2] P. Weisenburger, M. Luthra, B. Koldehofe, G. Salvaneschi: Quality-aware Runtime Adaptation in Complex Event Processing. In 2017 IEEE/ACM 12th International Symposium on Software Engineering for Adaptive and Self-Managing Systems (SEAMS) 2017
http://ieeexplore.ieee.org/document/7968142/

[3] [TCEP: Docker Image](TODO: define link to the docker hub mluthra/tcep)

[4] [GENI: an open infrastructure for at-scale networking and distributed systems](https://www.geni.net/)

### Credits
Design and Concepts: [@luthramanisha](https://github.com/luthramanisha/)

Implementation: [@rarif](https://github.com/raq154), Sebastian Hennig, [@luthramanisha](https://github.com/luthramanisha/)

TCEP is build upon AdaptiveCEP language that can be found [here](https://github.com/pweisenburger/AdaptiveCEP). 
