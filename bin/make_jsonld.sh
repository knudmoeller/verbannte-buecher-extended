#! /bin/bash

# This takes the original "Verbannte Bücher" JSON file (from
# https://web.archive.org/web/20140502133750/http:/daten.berlin.de/datensaetze/liste-der-verbannten-bücher)
# and transforms it into a JSON-LD file, using properties from
# schema.org, FOAF and custom properties.
# 
# requires https://stedolan.github.io/jq/
#
# 2018, Knud Möller

INPUT=$1
OUTPUT=$2

cat $INPUT | \
    jq --arg BASE "https://daten.berlin.de/sites/default/files" '{
            "@context": [
                "http://schema.org" ,
                {
                    "familyName": {
                        "@type": "xsd:string",
                        "@id": "http://xmlns.com/foaf/0.1/familyName"
                    } ,
                    "givenName": {
                        "@type": "xsd:string",
                        "@id": "http://xmlns.com/foaf/0.1/givenName"
                    } ,
                    "publisher": {
                        "@type": "xsd:string",
                        "@id": ($BASE + "/ref/verbannt.ttl#publisher")
                    } ,
                    "ocr_result": {
                        "@type": "xsd:string",
                        "@id": ($BASE + "/ref/verbannt.ttl#ocr_result")
                    }
                }
            ] ,
            "@graph": 
            [.[] | 
            { 
                "@type": (if (.title | test("Sämtliche")) then "Collection" else "CreativeWork" end) ,
                name: .title | ltrimstr(" ") | rtrimstr(" ") , 
                givenName: .authorFirstname | ltrimstr(" ") | rtrimstr(" ") , 
                familyName: .authorLastname | ltrimstr(" ") | rtrimstr(" ") , 
                publisher: .firstEditionPublisher | ltrimstr(" ") | rtrimstr(" ") , 
                ocr_result: .ocrResult | ltrimstr(" ") | rtrimstr(" ") , 
                dateCreated: .firstEditionPublicationYear | ltrimstr(" ") | rtrimstr(" ") } ] | 
            to_entries | 
            map({ "@id": ( $BASE + "/data/verbannte_buecher/entry/e_" + (.key|tostring))} + .value)
        }' > $OUTPUT