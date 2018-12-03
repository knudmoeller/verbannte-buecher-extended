require 'digest'

class PlaceHandler < Handler

  def initialize(args)
    super
    @place_column = args[:place_column]
    @conf = args[:conf]
  end

  def serialize
    if (place_name = @resource[@place_column])
      unless (is_null?(place_name))
        @json.merge!({
          "@type" => "Place"
        })
        @json['name'] = place_name
        add_same_as("gnd_#{@place_column}")
        place_id = Digest::SHA1.hexdigest(place_name)
        @json["@id"] = "#{@conf[:namespaces][:location]}pl_#{place_id}"
        return @json
      else
        return nil
      end
    end
  end  
  
end