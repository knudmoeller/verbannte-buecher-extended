class PlaceHandler < Handler

  def initialize(args)
    super
    @place_column = args[:place_column]
  end

  def serialize
    if (place_name = @resource[@place_column])
      unless (is_null?(place_name))
        @json.merge!({
          "@type" => "Place"
        })
        @json['name'] = place_name
        add_same_as("gnd_#{@place_column}")
        return @json
      else
        return nil
      end
    end
  end  
  
end