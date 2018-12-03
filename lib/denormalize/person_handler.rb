require_relative './handler.rb'
require_relative './place_handler.rb'

class PersonHandler < Handler
  
  def initialize(args)
    super
    @property_mapping.merge!({
      "name" => "preferred_name" ,
      "givenName" => "forename" ,
      "familyName" => "surname" ,
      "gender" => "gender" ,
      "birthDate" => "date_of_birth" ,
      "deathDate" => "date_of_death" ,
      "description" => "biographical_or_historical_information"
     })
    @place_property_mapping = {
      "birthPlace" => "place_of_birth" ,
      "deathPlace" => "place_of_death"
    }
    @conf = args[:conf]
  end

  def serialize
    @json.merge!({
      "@type" => "Person"
    })
    @property_mapping.keys.each do |property|
      add_data(property)
    end
    add_same_as('gnd')
    add_same_as('viaf')
    add_same_as('lc_naf')
    add_alternate_names
    @place_property_mapping.keys.each do |property|
      add_place(property)
    end
    @json["@id"] = "#{@conf[:namespaces][:person]}p_#{@resource['id']}"
    return @json
  end

  def add_alternate_names
    if (names = @resource['variant_names'])
      unless (is_null?(names))
        @json['alternateName'] = []
        names.each_line { |name| @json['alternateName'] << name.strip }
      end
    end
  end

  def add_place(property)
    if (column_name = @place_property_mapping[property])
      place_handler = PlaceHandler.new({ 
        :resource => @resource ,
        :place_column => column_name ,
        :conf => @conf
      })
      if (place = place_handler.serialize)
        @json[property] = place
      end
    end
  end
  
end