require_relative './handler.rb'


# s.n./s.l.:
# http://www.chicagomanualofstyle.org/qanda/data/faq/topics/Abbreviations/faq0007.html 

# @resource = {
#   :list_first_edition_publisher => "Westdt. Verlagsdr." ,
#   :list_first_edition_publication_year => 1930 ,
#   :list_first_edition_publication_place => "Düsseldorf" ,
#   :list_ocr_result => "Mit uns zieht die neue Zeit! Düsseldorf: Westdt. Verlagsdr. 1930." ,
#   :enhanced_publisher => "[s.n.] " ,
#   :enhanced_place_of_publication => "[s.l.]" ,
#   :enhanced_issued => 1920 ,
#   :enhanced_publication_statement => "[s. l.] @ : [s. n.] @, 1920" ,
#   :enhanced_geonames_place_of_publication => "NULL"
# }

# @resource = {
#   :list_first_edition_publisher => "Arbeiterjugend-Verlag" ,
#   :list_first_edition_publication_year => 1927 ,
#   :list_first_edition_publication_place => "Berlin" ,
#   :list_ocr_result => "Barthel, Max: Die Mühle zum Toten Mann. Berlin: Arbeiterjugend-Verl. 1927." ,
#   :enhanced_publisher => "Arbeiterjugend-Verlag" ,
#   :enhanced_place_of_publication => "Berlin" ,
#   :enhanced_issued => 1927 ,
#   :enhanced_publication_statement => "Berlin : Arbeiterjugend-Verlag, 1927" ,
#   :enhanced_geonames_place_of_publication => "http://sws.geonames.org/2950159/"
# }


class PublisherHandler < Handler

  def initialize(args)
    super
    @location_index = args[:location_index]
    @conf = args[:conf]
  end

  def serialize
    if (publisher = get_corrected_publisher)
      return publisher
    elsif (publisher = get_enhanced_publisher)
      return publisher
    elsif (publisher = get_list_publisher)
      return publisher
    else
      return nil
    end
  end

  def get_corrected_publisher
    row = @resource[:list_resource]["row"]
    correction = @conf[:publisher_corrections][row]
    unless is_null?(correction)
      publisher = {
        "@type" => "Organization" ,
        "name" => correction['publisher'] ,
        "provenance" => @conf[:provenances][:manual]
      }
      if (place = correction['location'])
        publisher[:location] = get_location(place)        
      end
      return publisher
    else
      return nil
    end
  end

  def get_enhanced_publisher
    unless is_null?(@resource[:enhanced_resource]['publisher']) || is_sn?(@resource[:enhanced_resource]['publisher'])
      publisher = {
        "@type" => "Organization" ,
        "name" => @resource[:enhanced_resource]['publisher'] ,
        "provenance" => @conf[:provenances][:dnb]
      }
      if (place = @resource[:enhanced_resource]['place_of_publication'])
        publisher[:location] = get_location(place)        
      end
      return publisher
    else
      return nil
    end
  end

  def get_list_publisher
    unless is_null?(@resource[:list_resource]['first_edition_publisher'])
      publisher = {
        "@type" => "Organization" ,
        "name" => @resource[:list_resource]['first_edition_publisher'] ,
        "provenance" => @conf[:provenances][:orig]
      }
      if (place = @resource[:list_resource]['first_edition_publication_place'])
        publisher[:location] = get_location(place)
      end
      return publisher
    else
      return nil
    end
  end

  def get_location(location_name)
    place_id = Digest::SHA1.hexdigest(location_name)
    location = {
      "@id" => "#{@conf[:namespaces][:location]}pl_#{place_id}" ,
      "@type" => "Place" ,
      "name" => location_name
    }
    if (sameAs = @location_index[location_name])
      location[:sameAs] = [ sameAs ]
    end
    return location
  end

  def is_sn?(publisher)
    return publisher.downcase.gsub(" ","").eql?("[s.n.]")
  end
  
  
end