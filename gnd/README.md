# Generating a subset from the DNB Dataset

The RDF datasets from DNB are huge (the main N-Triples file is ~60GB once unpacked). To facilitate easier processing with RDF tools, we 
want to prune it down to a manageable size.

## Download Sources

- RDF dumps are located at https://data.dnb.de/opendata/.
- We want the DNBTitle dataset as N-Triples: https://data.dnb.de/opendata/DNBTitel.nt.gz
- Unpack
- N-Triples are line-based, where each line is a triple of `<subject> <predicate> <object> .`:

```Turtle
...
<http://d-nb.info/351866043> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/ontology/bibo/Document> .
<http://d-nb.info/351866043> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/MusicRelease> .
<http://d-nb.info/351866043> <http://rdaregistry.info/Elements/u/P60049> <http://rdaregistry.info/termList/RDAContentType/1011> .
<http://d-nb.info/351866043> <http://rdaregistry.info/Elements/u/P60050> <http://rdaregistry.info/termList/RDAMediaType/1001> .
<http://d-nb.info/351866043> <http://rdaregistry.info/Elements/u/P60048> <http://rdaregistry.info/termList/RDACarrierType/1004> .
<http://d-nb.info/351866043> <http://purl.org/dc/elements/1.1/identifier> "(DE-101)351866043"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/351866043> <http://schema.org/productID> "Philips 416 633-2"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/351866043> <http://umbel.org/umbel#isLike> <http://nbn-resolving.de/urn:nbn:de:101:1-201603278995> .
<http://d-nb.info/351866043> <http://purl.org/dc/elements/1.1/identifier> "(OCoLC)725424771"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/351866043> <http://rdaregistry.info/Elements/u/P60048> <http://d-nb.info/gnd/4522869-3> .
<http://d-nb.info/351866043> <http://rdaregistry.info/Elements/u/P60327> "[Libretto: Lorenzo da Ponte]"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/351866043> <http://purl.org/dc/elements/1.1/title> "Cosi\u0300 fan tutte"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/351866043> <http://purl.org/dc/terms/creator> <http://d-nb.info/gnd/118584596> .
<http://d-nb.info/351866043> <http://id.loc.gov/vocabulary/relators/cmp> <http://d-nb.info/gnd/118584596> .
<http://d-nb.info/351866043> <http://id.loc.gov/vocabulary/relators/aut> <http://d-nb.info/gnd/118678841> .
...

```

## Extract Titles in Relevant Date Range

Publications in "Verbannte Bücher" are limited to a specific date range, so we only 
need the DNB subset from that date range: `1840--1945`.

### Extract relevant URIs

 We need the URIs of books published in this range. For the big N-Triples file, this translates to all lines matching one of the following patterns:

- `/<http://purl.org/dc/terms/issued> "19[01234]/`
- `/<http://purl.org/dc/terms/issued> "18[456789]/`

We use `grep` to filter those patterns and then merge the two results into one file:

```bash
$ grep '<http://purl.org/dc/terms/issued> "18[456789]' DNBTitel.nt > extracts/DNBTitel_issued-18--.nt
$ grep '<http://purl.org/dc/terms/issued> "19[01234]' DNBTitel.nt > extracts/DNBTitel_issued-19--.nt
$ cat extracts/DNBTitel_issued-1* > extracts/DNBTitel_issued_pre1945.nt
```

This matches all triples with the `dct:issued` property and a date approximately matching the ones we are looking for. We get some false positives from years > 1945, but that's probably negligible.

```Turtle
...
<http://d-nb.info/361005423> <http://purl.org/dc/terms/issued> "1846"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/361005431> <http://purl.org/dc/terms/issued> "1840"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/361006543> <http://purl.org/dc/terms/issued> "1872"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/361006551> <http://purl.org/dc/terms/issued> "1878"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://d-nb.info/361007752> <http://purl.org/dc/terms/issued> "1899"^^<http://www.w3.org/2001/XMLSchema#string> .
...
```

From the resulting list of triples, we extract only the subjects.

```bash
$ sed -E 's/^(<http:\/\/d-nb.info\/[^>]+\>) .+$/\1/' extracts/DNBTitel_issued_pre1945.nt > extracts/ids_pre1945.txt
```

This gives us a long list of publication URIs.

```
...
<http://d-nb.info/361005423>
<http://d-nb.info/361005431>
<http://d-nb.info/361006543>
<http://d-nb.info/361006551>
<http://d-nb.info/361007752>
...
```

### Extract only Interesting Properties

The complete `DNBTitel.nt` data contains lots of properties for each publication. For our purposes, we are only interested in a handful, which lets us further prune the list. We generate a file `properties.txt` with one interesting property URI on each line:

```
<http://purl.org/dc/elements/1.1/publisher>
<http://purl.org/dc/elements/1.1/title>
<http://purl.org/dc/terms/creator>
<http://rdaregistry.info/Elements/u/P60163>
<http://rdaregistry.info/Elements/u/P60327>
```

The `dce` and `dct` properties are self-explanatory. The meaning of the `rdau` properties is (they're URIs, you can look them up!):

- `rdau:P60163`: "has place of publication"
- `rdau:P60327`: "has statement of responsibility relating to title proper" - This is often the name of the author or something similar.

To extract only these properties from the main dataset, we can use our list as input for grep:

```bash
$ grep -F -f properties.txt DNBTitel.nt > extracts/DNBTitel_interesting_properties.nt
```

## Intersecting the two lists

Now we have two large files:

| File              | Description        | Size (#triples) |
| ----------------- | ------------------ | ---: |
| `ids_pre1945.txt` | The list of URIs of publications published between 1840--1949 | `1,384,072`  |
| `DNBTitel_interesting_properties.nt` | A list of interesting properties for all publications | `60,511,976`|

The task is to extract only those lines from `DNBTitel_interesting_properties.nt` which have a subject from `ids_pre1945.txt`.

We do the following:

- Load the list of URIs into memory.
- Go through the interesting properties file triple by triple (i.e., line by line).
- If the subject of the triple is contained in `ids_pre1945.txt`, write the triple to a new file `interesting_properties_pre1945.nt`.

We'll do this in Python. The complete program with a nice progress bar, etc. is in [bin/filter.py](bin/filter.py), but here is the gist of it:

```python
ids = set()
num_ids = 0
with open('ids_pre1945.txt') as id_file:
    for line in id_file:
        num_ids += 1
        line = line.strip()
        ids.add(line)

# open output file
outfile = open('interesting_properties_pre1945.nt', 'w')

# iterate through interesting properties file
with open('DNBTitel_interesting_properties.nt') as triples:
    for triple in triples:
        # we can get the parts of the triple with a simple split()
        # (this will fail for string objects with spaces, but we're
        # only interested in the subject part, which does not contain
        # spaces - it's a URI)
        parts = triple.split()
        if len(parts) > 0:
            subject = parts[0]
            # this is the crucial lookup:
            if subject in ids:
                outfile.write(triple)

# and close
outfile.close
```

One crucial aspect here is to do the lookup on a set (which uses hashes), rather than a list. For a discussion of the reasons, see: https://stackoverflow.com/questions/513882/python-list-vs-dict-for-look-up-table

To give an impression, here is the time required to do 1000 lookups in `ids_pre1945.txt` on my machine:

| list lookup | set lookup |
| ----------: | ---------: |
| ~15.2s      | ~0.015s    |


Now, instead of the 60,511,976 triples we had in the original file, we have a manageable amount 5,703,073.


