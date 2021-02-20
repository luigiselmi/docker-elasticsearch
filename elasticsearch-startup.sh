#!/bin/bash

set -e

echo `date` $0

( # run concurrent to elasticsearch:
    while ! ( ./healthcheck ) ;do echo expect to become healthy; sleep 5; done
    echo XXX $0 initialisation finished, service is healthy
    curl -XPUT "localhost:9200/thessaloniki"
    echo XXX $0 index created
    curl -XPUT "localhost:9200/thessaloniki/_mapping/floating-cars?include_type_name=true" -H "Content-Type: application/json" -d "@/fcd-mapping.json"
    echo XXX $0 mapping schema defined
) &
    
echo $0 

exec bin/elasticsearch

