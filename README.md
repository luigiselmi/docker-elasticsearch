docker-elasticsearch
====================
Docker image for Elasticsearch with an example index and a schema. To build an image using this docker file execute the following command

    $ docker build -t lgslm/elasticsearch:v1.0.0 .

To run a container in detached mode execute the command
 
    $ docker run --rm -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" lgslm/elasticsearch:v1.0.0 

To attach to the running container execute the command

    $ docker exec -it elasticsearch bash

The script elasticsearch-startup.sh, included in the Dockerfile, creates an index "thessaloniki" and sends a schema, aka mapping, as a JSON
file

    $ curl -XPUT "http://localhost:9200/thessaloniki/_mapping/floating-cars?include_type_name=true" -H "Content-Type: application/json" -d @fcd-mapping.json

The schema defines the index fields
 
```
{
  "floating-cars" : {
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
```

 
