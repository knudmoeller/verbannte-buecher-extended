class Conf

  def Conf.conf
    conf = {
      :sources => {
        :list => "list.xml" ,
        :people => "person.csv" ,
        :publication => "publication.csv" ,
        :mapping => "publicationPerson.csv"
      } ,
      :output_json => "verbannte_buecher_neu.json" ,
      :namespaces => {
        :base => "https://daten.berlin.de/sites/default/" ,
      } ,
      :provenances => {
        :dnb => "DNB linked data" ,
        :orig => "Original list 'Verbannte Bücher'" ,
        :manual => "Manual corrections"
      } ,
      :vocabs => {
        :vb => {
          "row": {
            "@type": "xsd:integer"
          } ,
          "ss_flag": {
            "@type": "xsd:boolean"
          } ,
          "page_number_in_ocr_document": {
            "@type": "xsd:integer"
          },
          "ocr_result": {
            "@type": "xsd:string"
          },
          "corrections_after_1938": {
            "@type": "xsd:string"
          }
        } ,
        :owl => {
          "sameAs": {
            "@type": "@id",
            "@id": "http://www.w3.org/2002/07/owl#sameAs"
          }
        } ,
        :dct => {
          "provenance": {
            "@type": "xsd:string",
            "@id": "http://purl.org/dc/terms/provenance"
          }
        }
      }
    }

    conf[:vocabs][:vb].keys.each do |term|
      conf[:vocabs][:vb][term]["@id"] = "#{conf[:namespaces][:base]}ref/verbannt\##{term}"
    end

    conf[:namespaces][:entry] = "#{conf[:namespaces][:base]}data/verbannte_buecher/entry/"
    conf[:namespaces][:location] = "#{conf[:namespaces][:base]}data/verbannte_buecher/location/"
    conf[:namespaces][:publication] = "#{conf[:namespaces][:base]}data/verbannte_buecher/publication/"
    conf[:namespaces][:person] = "#{conf[:namespaces][:base]}data/verbannte_buecher/person/"


    return conf
  end
  
end