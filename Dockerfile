# Dockerfile for Elasticsearch. This image creates an index and a schema (mapping) 
# To build an image using this docker file, execute the following command
#
# $ docker build -t lgslm/elasticsearch:v1.0.0 .
#
# To run a container with Elasticsearch in single node execute the command
# 
# $ docker run --rm -d --name elasticsearch --network kafka-clients-net -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" lgslm/elasticsearch:v1.0.0 
#
# To attach to the running container execute the command
#
# $ docker exec -it elasticsearch bash
#
# The base image of elasticsearch:7.10.1 is centos:8.
FROM elasticsearch:7.10.1

MAINTAINER Luigi Selmi <luigi@datiaperti.it>

# Install nano for editing
RUN yum install -y nano

# copy files to create the thessaloniki index in /usr/share/elasticsearch
COPY healthcheck .
COPY thessaloniki-settings.json .
COPY elasticsearch-startup.sh .

# elasticsearch cannot be run by root
USER elasticsearch

ENTRYPOINT ["./elasticsearch-startup.sh" ]
