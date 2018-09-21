#!/bin/bash
iperf3 -s -D
ntpd -s
java -Done-jar.main.class=${MAIN} -Dconstants.gui-endpoint="http://localhost:3000" -jar /app/tcep_2.12-0.0.1-SNAPSHOT-one-jar.jar ${ARGS}
