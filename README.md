docker-elasticsearch
====================
Docker image for Elasticsearch with an example index and a schema. To build an image using this docker file execute the following command

    $ docker build -t lgslm/elasticsearch:v1.0.0 .

To run a container in detached mode execute the command
 
    $ docker run --rm -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" lgslm/elasticsearch:v1.0.0 

To attach to the running container execute the command

    $ docker exec -it elasticsearch bash

The script elasticsearch-startup.sh, included in the Dockerfile, creates an index "thessaloniki" and sends the settings, such as the number 
of shards in which we split the index and the number of replicas of the shards

    $ curl -XPUT "http://localhost:9200/thessaloniki?include_type_name=true" -H "Content-Type: application/json" -d @thessaloniki-settings.json

The file contains the mappings as well, that is the fields of the index.
 
```
{
  "settings" : {
     "number_of_shards": 1,
     "number_of_replicas": 1
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
We can now index some data  

    $ curl -XPOST "http://localhost:9200/thessaloniki/_doc" -H "Content-Type: application/json" -d @fcd-data.json

sending the data as a JSON file to the elasticsearch docker container. In case the container is not a local container we must 
use its service name or hostname. 

``` 
{
  "geohash" : "sq0r",
  "timestamp" : "2021-02-20 18:00:00",
  "location" : {
      "lat": 42.12,
      "lon": 12.25
    },
  "speed" : 42.50,
  "orientation" : 180.5,
  "count" : 1
}

```
Finally, we can send a query, for example to know the number of records with the parameter geohash=sx0* that covers the area 
of Thessaloniki and Halkidiki

    $ curl "http://localhost:9200/thessaloniki/_count?q=geohash:sx0*"

and get the response

```
{"count":1,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0}}
```
The service can be started using the docker-compose file

    $ docker-compose up -d
