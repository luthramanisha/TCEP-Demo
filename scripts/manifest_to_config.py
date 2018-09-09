#!/usr/bin/python
# Description: Parses the Manifest XML file downloaded from GENI and outputs
# the hosts IP addresses in the config file format

import sys
import xml.etree.ElementTree
import fileinput

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

worker_str = "workers=("

for ip in ip_array:
    worker_str += "\"" + ip + "\" "

worker_str += ")"

cfg = "manager=" + manager_ip + "\n" + worker_str + "\n"
replaced = False

for line in fileinput.input("../docker-swarm.cfg", inplace=True):
    if replaced != True and (line.startswith("workers=(") or line.startswith("manager=")):
        print cfg.rstrip()
        replaced = True
        continue
    elif replaced and (line.startswith("workers=(") or line.startswith("manager=")):
        continue
    else:
        print line.rstrip()
