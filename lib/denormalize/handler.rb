require 'uri'

class Handler
  
  attr_reader :resource, :json, :property_mapping

  def initialize(args)
    @resource = args[:resource]
    @json = {}
    @property_mapping = {}
  end
  
  def add_same_as(column_header)
    if (same_as_uris = @resource[column_header])
      same_as_uris = URI.extract(same_as_uris.strip)
      if same_as_uris.count > 0
        @json['sameAs'] = [] unless @json['sameAs']
        @json['sameAs'].concat(same_as_uris) 
      end 
    end
  end
  
  def add_data(property)
    column_header = @property_mapping[property]
    if (value = @resource[column_header])
      @json[property] = value unless is_null?(value)
    end
  end

  def boolarize(string)
    if (string.eql?("0"))
      return false
    else
      return true
    end
  end

  def is_null?(value)
    if !value
      return true
    elsif value.eql?("NULL")
      return true
    elsif value.eql?("")
      return true
    else
      return false
    end
  end

end