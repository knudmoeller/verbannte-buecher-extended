require 'uri'
require 'pp'

require_relative './handler.rb'

class EntryHandler < Handler

  def initialize(args)
    super
    @conf = args[:conf]
    @people = args[:people]
    @people_by_gnd = args[:people_by_gnd]
    @publications = args[:publications]
    @publications_by_row = args[:publications_by_row]
    @mappings = args[:mappings]
    @publications_by_author = args[:publications_by_author]
  end
  
  def serialize
    @json = Hash[@conf[:vocabs][:vb].keys.map { |term| convert_attribute(term.to_s) }.compact ]
    @json["@id"] = "#{@conf[:namespaces][:entry]}e_#{@json['row']}"
    add_same_as('title_gnd')
  end

  def convert_attribute(attribute)
    if (is_null?(@resource[attribute]))
      return nil
    end
    case attribute
    when "ss_flag"
      return [ attribute, boolarize(@resource[attribute]) ]
    else
      return [ attribute, @resource[attribute] ]
    end
  end

end