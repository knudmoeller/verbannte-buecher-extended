#! /bin/bash

DATA=$1
echo $DATA

riot --syntax=jsonld $DATA/target/verbannte_buecher_neu.json | \
    rapper -i ntriples -o turtle \
    -f 'xmlns:schema="http://schema.org/"' \
    -f 'xmlns:dct="http://purl.org/dc/terms/"' \
    -f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' \
    -f 'xmlns:verbannt="https://daten.berlin.de/sites/default/files/ref/verbannt.ttl#"' \
    -f 'xmlns:entry="https://daten.berlin.de/sites/default/files/data/verbannte_buecher/entry/"' \
    -f 'xmlns:location="https://daten.berlin.de/sites/default/files/data/verbannte_buecher/location/"' \
    -f 'xmlns:person="https://daten.berlin.de/sites/default/files/data/verbannte_buecher/person/"' \
    --input-uri https://daten.berlin.de/sites/default/files/data/verbannte_buecher/ - > \
    $DATA/target/verbannte_buecher_neu.ttl