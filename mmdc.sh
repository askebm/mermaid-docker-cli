#!/bin/bash
INPUT="${@}"
CONTAINER="minlag/mermaid-cli"

INPUT2=$(echo "${INPUT}" | sed -E 's+(([^-]|)-[iocCp] ?)(\S\+)+\1'"${PWD}/"'\3+g')
INPUT3=$(echo "${INPUT2}" | sed -E \
	's+( ?--(input|output|configFile|cssFile|puppeteerConfigFile) ?)(\S\+)+\1'"${PWD}/"'\2+g')

docker run -it --rm -v ${PWD}:${PWD} ${CONTAINER} mmdc ${INPUT3}

