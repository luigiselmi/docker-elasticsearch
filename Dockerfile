# Dockerfile for Elasticsearch. This image creates an index and a schema (mapping) 
# To build an image using this docker file, execute the following command
#
# $ docker build -t lgslm/elasticsearch:v1.0.0 .
#
# To run a container in detached mode execute the command
# 
# $ docker run --rm -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" lgslm/elasticsearch:v1.0.0 
#
# To attach to the running container execute the command
#
# $ docker exec -it elasticsearch bash
#
FROM elasticsearch:7.10.1

MAINTAINER Luigi Selmi <luigi@datiaperti.it>

WORKDIR /
COPY healthcheck /
COPY fcd-mapping.json /
COPY elasticsearch-startup.sh /

CMD [ "/elasticsearch-startup.sh" ]
