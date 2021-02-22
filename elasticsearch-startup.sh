#!/bin/bash

set -e

echo `date` $0

( # run concurrent to elasticsearch:
    while ! ( ./healthcheck ) ;do echo expect to become healthy; sleep 5; done
    echo XXX $0 initialisation finished, service is healthy
    curl -XPUT "http://localhost:9200/thessaloniki?include_type_name=true" -H "Content-Type: application/json" -d @thessaloniki-settings.json
    echo XXX $0 index with mapping created
) &
    
echo $0 

exec bin/elasticsearch

