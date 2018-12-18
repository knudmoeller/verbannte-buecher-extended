#! /bin/bash

INPUT=$1
OUTPUT=$2
BASE=$3

riot --syntax=jsonld $INPUT | \
    rapper -i ntriples -o turtle \
    -f 'xmlns:schema="http://schema.org/"' \
    -f 'xmlns:foaf=""http://xmlns.com/foaf/0.1/"' \
    -f 'xmlns:dct="http://purl.org/dc/terms/"' \
    -f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' \
    -f 'xmlns:verbannt="$BASE/ref/verbannt.ttl#"' \
    -f 'xmlns:entry="$BASE/data/verbannte_buecher/entry/"' \
    -f 'xmlns:location="$BASE/data/verbannte_buecher/location/"' \
    -f 'xmlns:person="$BASE/data/verbannte_buecher/person/"' \
    --input-uri $BASE/data/verbannte_buecher/ - > \
    $OUTPUT