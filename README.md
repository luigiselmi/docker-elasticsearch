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

In case the container is not a local container we must use its service name or hostname. The example data file contains two records 

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

One other common query is to know the number of records with a field that contains a certain value, e.g. geohash=sx0* 

    $ curl "http://localhost:9200/thessaloniki/_count?q=geohash:sx0*"


The Elasticsearch single-node container can also be started using the docker-compose file

    $ docker-compose up -d

The index is saved in a local volume so that it will still be available in case the container is stopped and restarted.
## cluster
