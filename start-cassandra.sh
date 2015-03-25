#!/bin/bash

CONFIG_FILE=/apache-cassandra/conf/cassandra.yaml

LISTEN_ADDRESS=${CASSANDRA_LISTEN_ADDRESS?NOT DEFINED}

# Unclear to me whether this is an issue with the datastax env code, but
# for the version of jdk we're using 228k is the minimum accepted stack size,
# tweak the config
# TODO investigate the reason for this.

sed -i -e "s@-Xss180k@-Xss228k@" /apache-cassandra/conf/cassandra-env.sh

sed -i \
    -e "s@localhost@${LISTEN_ADDRESS}@" \
    -e "s@127\.0\.0\.1@${LISTEN_ADDRESS}@g" ${CONFIG_FILE}

echo -e "data_file_directories:\n  -   /data/cassandra/${HOSTNAME}/" >> ${CONFIG_FILE}


/apache-cassandra/bin/cassandra -f
