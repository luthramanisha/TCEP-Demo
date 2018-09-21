#!/usr/bin/python

# File name: manifest_to_config.py
# Author: Sebastian Hennig
# Date created: 18.07.2018
# Python Version: 2.7
# Description: Parses the Manifest XML file downloaded from GENI and outputs
# the hosts IP addresses in the config file format

import os
import sys
import re
import xml.etree.ElementTree

project_root = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..")
e = xml.etree.ElementTree.parse(sys.argv[1]).getroot()

manager_ip = ""
ip_array = []

# Iterate through all nodes in the array
for child in e.findall('{http://www.geni.net/resources/rspec/3}node'):
    # This selects the first IP address found as the manager node IP
    if not manager_ip:
        manager_ip = child.find('{http://www.geni.net/resources/rspec/3}host').attrib['ipv4']
        continue
    ip_array.append(child.find('{http://www.geni.net/resources/rspec/3}host').attrib['ipv4'])

worker_str = "("
for ip in ip_array:
    worker_str += "\"" + ip + "\" "
worker_str += ")"

config_file = open(os.path.join(project_root, "scripts/templates/docker-swarm.cfg"), "r")
config = config_file.read()
config_file.close()

config = config.replace("{{workers}}", worker_str).replace("{{manager}}", manager_ip)

print(os.path.join(project_root, "docker-swarm.cfg"))
config_file = open(os.path.join(project_root, "docker-swarm.cfg"), "w")
config_file.write(config)
config_file.close()

applicationConfPath = os.path.join(project_root, "dockerbuild/docker-entrypoint.sh")
with open(applicationConfPath) as f:
    applicationConf = re.sub('-Dconstants.gui-endpoint=\"(.*?)\"', '-Dconstants.gui-endpoint="http://' + manager_ip + ':3000"', f.read())

with open(applicationConfPath, "w") as f:
    f.write(applicationConf)

graphPath = os.path.join(project_root, "gui/graph.html")
with open(graphPath) as f:
    graph = re.sub('const SERVER_URL = \"(.*?)\"', 'const SERVER_URL = "http://' + manager_ip + ':3000/data"', f.read())

with open(graphPath, "w") as f:
    f.write(graph)
