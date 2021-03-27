docker-elasticsearch
====================
This repository contains a Dockerfile, bash scripts and docker-compose files to create an Elasticsearch index in single node or in cluster.

## single-node 
A Docker image of Elasticsearch (v.7.10.1) with an index can be built using the docker file available in this repository with the following 
command

    $ docker build -t lgslm/elasticsearch:v1.0.0 .

The Dockerfile includes a script that waits till Elasticsearch is ready and then sends the settings to create an index named "thessaloniki" 
with 1 shard and two replicas. The number of replicas can be changed afterwards. To run a container with Elasticsearch in single-node execute 
the command
 
    $ docker run --rm -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" lgslm/elasticsearch:v1.0.0 

To attach to the running container execute the command

    $ docker exec -it elasticsearch bash

As said, the script elasticsearch-startup.sh, included in the Dockerfile, creates an index "thessaloniki" and sends the settings, such as the 
number of shards in which we split the index and the number of replicas of the shards

    $ curl -XPUT "http://localhost:9200/thessaloniki?include_type_name=true" -H "Content-Type: application/json" -d @thessaloniki-settings.json

The index is created when the container starts so there is no need to use the command again. The file "thessaloniki-settings.json" contains the 
mappings of the fields of the index with their data type.
 
```
{
  "settings" : {
     "number_of_shards": 1,
     "number_of_replicas": 2
  },
  "mappings" : {
     "fcd" : {
        "properties" : {
           "geohash" : {"type": "text"},
           "timestamp" : {"type": "date",
                      "format": "yyyy-MM-dd HH:mm:ss"
            },
           "location" : {"type": "geo_point"},
           "speed" : {"type": "double"},
           "orientation" : {"type": "double"},
           "count" : {"type": "integer"}
     }
   }
  }
}

```
After the container is started we can index some data by sending it as a JSON file to the elasticsearch node within the docker 
container

    $ curl -XPOST 'http://localhost:9200/thessaloniki/_doc' -H "Content-Type: application/json" -d @fcd-data.json

In case the container is not a local container we must use its service name or hostname. A record looks like the following  

``` 
{
  "geohash" : "sx0r",
  "timestamp" : "2021-02-20 17:59:00",
  "location" : {
      "lat": 42.11,
      "lon": 12.35
    },
  "speed" : 30.00,
  "orientation" : 97.2,
  "count" : 1
}

```
It is also possible to send multiple records in a single request using the Elasticsearch's Bulk API

    $ curl -XPOST 'http://localhost:9200/thessaloniki/_bulk' -H "Content-Type: application/json" --data-binary @fcd-data-bulk.json

Finally, we can send queries, for example to search for all the documents in which the value of the "geohash" field starts with "sx0"
that is, records that cover the area of Thessaloniki and the Halkidiki peninsula

    $ curl 'http://localhost:9200/thessaloniki/_search?q=geohash:sx0*&pretty'

One other common query is to know the number of records with a field that contains a certain value, e.g. geohash=sx0*, as in the previous 
request

    $ curl "http://localhost:9200/thessaloniki/_count?q=geohash:sx0*"


The Elasticsearch single-node container can also be started using the docker-compose file

    $ docker-compose up -d

The index will be saved in a local volume so that it will still be available in case the container is stopped and restarted. In order to 
delete all the documents in a index we can use the Delete by query API request with the command

    $  curl -XPOST 'http://localhost:9200/thessaloniki/_delete_by_query?pretty' -H "Content-Type: application/json" --data-binary @bulk-delete.json

where the file bulk-delete.json contains the request
```
{
  "query": {
    "match_all": {}
   }
}

```

## cluster
As an example we provide the docker-compose file to create a cluster of three Elasticsearch nodes to be deployed on three different servers 
as Docker containers. In the first container we use the image built on top of the official Elasticsearch Docker image, version 7.10.1, that 
contains the script to create the index we used before. The other two container use the official image. The configuration has been tested 
on a cluster of three Amazon EC2 server instances (t3.medium: 2 vCPU, 4 GB mem, 16 GB SSD storage). Docker Engine and docker-compose must be 
installed on each EC2 instance. The container can be managed using Docker in swarm mode. The setup of a Docker swarm is described in the [Docker
website](https://docs.docker.com/engine/swarm/) or more briefly [here](https://github.com/luigiselmi/docker-zookeeper#quorum-mode-cluster).
One important setting before running the containers is to set the value of the virtual memory dedicated to a shard to at least 262144 as
recommended on the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/vm-max-map-count.html). The 
virtual memory can be set on each instance using the command

    $ sudo sysctl -w vm.max_map_count=262144       
 
or by setting the variable in /etc/sysctl.conf. When the instanes are available we have to just install the Docker images used in the 
docker-compose file and finally deploy the stack of services using Docker in swarm mode from the master

    $ docker stack deploy -c docker-compose-es-cluster.yml es-stack
