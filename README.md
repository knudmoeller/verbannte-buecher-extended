# "Verbannte Bücher" Extended

This project extends the originally published list of banned books in Germany 
from 1933 with additional data from the German National Library's GND
(Gemeinsame Normdatei) or Integrated Authority File. In particular, it enriches
the data with details about authors and 
expands occurrences of _"all works by this authors"_ to the actual list of works.
The output of this project is one big JSON-LD file.

The current incarnation of the original "Verbannte Bücher" project can be found at
https://www.berlin.de/berlin-im-ueberblick/geschichte/berlin-im-nationalsozialismus/verbannte-buecher ;
access to the data can be gained through the Open Data portal of Berlin at
https://daten.berlin.de/datensaetze/liste-der-verbannten-bücher.

## Sources

- **Original JSON Source**: The original JSON source is no longer available
  (they were part of an older incarnation of the project), except through
  archive.org:
  https://web.archive.org/web/20140502133750/http:/daten.berlin.de/datensaetze/liste-der-verbannten-bücher.
  It is also included in this repository at 
  [/data/reference/verbannte-buecher-ref.json](data/reference/verbannte-buecher-ref.json).
  The original JSON has been published by Wolfgang Both under [CC BY 3.0 DE](https://creativecommons.org/licenses/by/3.0/de/).
- **Coding Da Vinci Project**: There was a project at the first
  [Coding Da Vinci](https://codingdavinci.de) culture hackathon event, which 
  integrated the original JSON data with data from the GND and built an 
  application around that: https://github.com/jlewis91/codingdavinci. 
  Most of the heavy lifting required to integrate the original list with the GND data was done in this project.
  The 
  publication and person data generated in this project were published as an 
  SQL dump, and are here included as CSV files at 
  - [/data/source/person.csv](data/source/person.csv)
  - [/data/source/publication.csv](data/source/publication.csv)
  - [/data/source/publicationPerson.csv](data/source/publicationPerson.csv)
- **Manual Corrections**: The data extracted from the OCR scans is not always
  correct. E.g., some ORC strings contain publisher and place of publication,
  but the corresponding extracted fields say "[s.n.]" (_sine nomine_) or
  "[s.l.]" (_sine loco_), respectively. Whenever errors such as those are
  detected, they are corrected in additional files such as 
  [/data/source/publisher_corrections.json](data/source/publisher_corrections.json), 
  which are then used in the conversion process.

## Output JSON-LD

The output of the conversion process is a [JSON-LD file](data/target/verbannte_buecher_neu.json) that follows the original JSON in its structure. The vocabulary used is mainly schema.org. 

- The entry point is the list itself, which is modelled as an instance of
  [schema:ItemList](https://schema.org/ItemList) (and also 
  [schema:CreativeWork](https://schema.org/CreativeWork)).
- Each entry in the list is connected to the list via [schema:itemListElement](https://schema.org/itemListElement).
- Every entry is either a generic [schema:CreativeWork](https://schema.org/CreativeWork) (in case the original list stated a specific publication) or a [schema:Collection](https://schema.org/Collection) (in case the original list stated that _"sämtliche Schriften"_, i.e. all works by this author, were to be banned).
- In the case of a [schema:Collection](https://schema.org/Collection), the individual works as extracted from GND are connected via [schema:hasPart](https://schema.org/hasPart).
- Individual publications usually have a [schema:author](https://schema.org/author) and a [schema:publisher](https://schema.org/publisher).
- Authors are of type [schema:Person](https://schema.org/Person), and can have detailed information such as date and place of birth and death, alternate names and gender.
- There are also usually [owl:sameAs](http://www.w3.org/2002/07/owl#sameAs) links for author objects, linking them to representations of the same author in other datasets (such as VIAF or the GND).
- Publishers are of type [schema:Organization](https://schema.org/Organization), which can also have additional information such as location.
- Places/Locations are of type [schema:Place](https://schema.org/Place) (usually cities), with links to other representations of the same place (such as the GND or Geonames).

## Errors in the Data and hot to Fix them

The linking between entries in the original list and resources in the GND was done in the Coding Da Vinci project. The result is fantastic and I imagine very useful for people interested in the list, but there are errors in the data. Usually such errors are wrong links, where a publication from the list was connected to something that is not actually the same in GND. Because the JSON-LD conversion script uses this data, the resulting JSON-LD data will have the same errors. The hope is that, over time, these errors can be detected and corrected, and new versions of the JSON-LD list will be released.

If you find errors, let us know here on github via by posting an issue. Pull requests are also highly welcome. Ideally, if you want to fix an error, try to fix it in the source data files in [/data/source](data/source).

## License

All software in this project (in particular the Ruby code) is published under the [MIT License](LICENSE). All data in this project (in particular the generated JSON-LD list) is published under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).