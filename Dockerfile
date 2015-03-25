FROM mastodonc/basejava

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y -q python2.7 && \
    apt-get clean && \
    apt-get autoclean

RUN curl -sL http://mirror.ox.ac.uk/sites/rsync.apache.org/cassandra/2.1.3/apache-cassandra-2.1.3-bin.tar.gz | \
    tar -xzf - -C / --transform 's@\([a-z-]*\)-[0-9\.]*@\1@'

ADD start-cassandra.sh /start-cassandra

############################################
# Make Oracle JDK the default.

CMD ["/bin/bash","/start-cassandra"]

# 9042 is CQL, 9160 is thrift
# TODO - remove thrift?
EXPOSE 9042 9160
