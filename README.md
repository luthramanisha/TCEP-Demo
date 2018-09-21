# TCEP Demonstrator

[![License](https://img.shields.io/github/license/luthramanisha/TCEP-Demo.svg)](https://github.com/luthramanisha/TCEP-Demo)
[![Issues](https://img.shields.io/github/issues/luthramanisha/TCEP-Demo.svg)](https://github.com/luthramanisha/TCEP-Demo)
[![hitCount](http://hits.dwyl.io/luthramanisha/TCEP-Demo.svg)](http://hits.dwyl.io/luthramanisha/TCEP-Demo)

## TCEP Background Information
TCEP: Transition-capable Complex Event Processing is a research project that provides abstractions to develop an adaptive Complex Event Processing (CEP) system [1]. In this project, we: 
* provide key interfaces to develop Operator Placement that is a prominent mechanism in CEP [2]. 
* allow dynamic exchange of Operator Placement algorithms using *transition* methodology, depending on the needs of the end-user and environment 
* allow operator deployment on a wide-range of network infrastructure by providing key APIs to integrate with Docker.

In the following, we demonstrate how TCEP can be seamlessly evaluated on GENI [4] aiding in understanding behavior of Operator Placement on large-scale network infrastructure. 

## Running on GENI
![TCEP on GENI workflow](/figures/Workflow.JPG)

GENI provides a large-scale experiment infrastructure where users can obtain computing instances throughout the United States to perform network experiments [4].
We provide useful scripts to enable easier evaluation of TCEP [1] on GENI which are described below. 

*Although focus of this demo is to show the capabilities of TCEP, but the user can use the scripts to run *any* kind of distributed application using our Docker container environment on GENI testbed.*

To execute TCEP on GENI, please follow the below steps.

```
cd scripts/
```

First, a so called RSpec XML file is needed in order to get a GENI cluster up and running. To automatically generate this file for a cluster with a specified number of nodes you can execute the following command:

```
python generate_specification.py {number-of-nodes} {out-directory}
```

This will generate the `rspec.xml` file at `out-directory` with the specified number of nodes. Furthermore, this also generate the Docker swarm file "docker-stack.yml" with the correct amount of empty apps running on the GENI hosts at the project root. Refer `out/` directory to see the samples. 

After you deployed the RSpec on GENI, you can download a Manifest XML file which contains information of the hosts that GENI deployed (View Rspec on the Jacks resources page). This is useful because GENI automatically generates IP addresses for the hosts and if you created a cluster with a high amount of nodes the search for this IP addresses can be a heavy overhead. A holder for `manifest.xml` exists in `scripts/` folder, where you copy the configuration.
After downloading the manifest file you can run the following command to extract the IP addresses out of it and generate the config `docker-swarm.cfg` file in the project root folder:

```
python manifest_to_config.py {manifest-path}
```

This will convert the manifest and will print out the IP addresses of the started hosts in the config format for the docker deploy script. You should be able to see the IP addresses in docker-swarm.cfg in the following format: 

```
manager=xx.xx.xx.xx
workers=("xx.xx.xx.xx" "xx.xx.xx.xx")
```

Now since the hosts are successfully deployed on GENI and the project is ready to be setup on the hosts. To setup the GENI instances to be able to run docker, run the following command:

```
bash publish_tcep.sh setup
```

Note that you maybe have to enter `yes` in the console multiple times to allow SSH connections to the hosts

After the instances are all setup, you can go forward and finally run TCEP and GUI docker images [4] on the hosts. We provide two modes of TCEP execution. You can either (i) pull the provided image of TCEP or (ii) build TCEP (requires docker login to build and push the image) that also enables your personalized TCEP GUI view. 

## Option 1
```
bash publish_tcep.sh all
```
Open the webpage http://171.67.2.62:3000/ to look at the transition execution.

## Option 2

### Prerequisites 
* working credentials on docker hub (registry)
* replace "registry_user" with your docker hub username

```
bash build.sh && bash publish_tcep.sh all
```
To visualize the placement and transition execution on GENI nodes [5], please our frontend at http:<MANAGER_IP:3000> as shown below. 

![TCEP-GUI on GENI](/figures/TCEP-GUI.jpg)

### References:

[1] M. Luthra, B. Koldehofe, R. Arif, P. Weisenburger, G. Salvaneschi. TCEP: Adapting to Dynamic User Environments by Enabling Transitions between Operator Placement Mechanisms. In the Proceedings of 12th ACM International Conference on Distributed and Event-based Systems (DEBS) 2018
https://dl.acm.org/citation.cfm?id=3210292

[2] P. Weisenburger, M. Luthra, B. Koldehofe, G. Salvaneschi. Quality-aware Runtime Adaptation in Complex Event Processing. In 2017 IEEE/ACM 12th International Symposium on Software Engineering for Adaptive and Self-Managing Systems (SEAMS) 2017
http://ieeexplore.ieee.org/document/7968142/

[3] [TCEP and TCEP-GUI Docker image](https://hub.docker.com/r/mluthra/)

[4] [GENI: an open infrastructure for at-scale networking and distributed systems](https://www.geni.net/)

[5] [D3 js library](https://github.com/d3/d3)

### Credits
Design and Concepts: [@luthramanisha](https://github.com/luthramanisha/)

Implementation: [@rarif](https://github.com/raq154), [@shennig](https://github.com/ocastx), [@luthramanisha](https://github.com/luthramanisha/)

TCEP is build upon AdaptiveCEP language [2] that can be found [here](https://github.com/pweisenburger/AdaptiveCEP). 

### Acknowledgements

This work has been co-funded by the German Research Foundation (DFG) as part of the sub-project C2 within the Collaborative Research Center (CRC) 1053 -- MAKI.
