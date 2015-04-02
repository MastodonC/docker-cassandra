#!/bin/bash

CONFIG_FILE=/apache-cassandra/conf/cassandra.yaml

LISTEN_ADDRESS=${CASSANDRA_LISTEN_ADDRESS:-$(hostname -i)}


# tabs not allowed
YML_INDENT="    "

DIR_TAIL="cassandra/${HOSTNAME}"
LOGS_DIR="/logs/${DIR_TAIL}"

function join { local IFS="$1"; shift; echo "$*"; }

if [ -z "${DATA_DIR_PATTERN}" ] ; then
    DATA_DIRS="/data/${DIR_TAIL}"
    mkdir -p ${DATA_DIRS}
else
    ddirs=()
    candidates=(${DATA_DIR_PATTERN})
    for dir in ${candidates[@]}
    do
	thedir="$(pwd)${dir}/${DIR_TAIL}"
	mkdir -p ${thedir}
	ddirs+=("${thedir}")
    done
    DATA_DIRS=$(join "\n${YML_INDENT}-" ${ddirs[@]})
fi

echo "CASSANDRA_LISTEN_ADDRESS is ${CASSANDRA_LISTEN_ADDRESS}"
echo "DATA_DIRS is ${DATA_DIRS}"

mkdir -p "${LOGS_DIR}"

# Unclear to me whether this is an issue with the datastax env code, but
# for the version of jdk we're using 228k is the minimum accepted stack size,
# tweak the config
# TODO investigate the reason for this.

sed -i -e "s@-Xss180k@-Xss228k@" /apache-cassandra/conf/cassandra-env.sh

sed -i \
    -e "s@localhost@${LISTEN_ADDRESS}@" \
    -e "s@127\.0\.0\.1@${LISTEN_ADDRESS}@g" ${CONFIG_FILE}

echo -e "data_file_directories:\n${YML_INDENT}- ${DATA_DIRS}" >> ${CONFIG_FILE}

/apache-cassandra/bin/cassandra -f
