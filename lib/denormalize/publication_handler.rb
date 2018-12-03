require 'pp'
require_relative "./entry_handler.rb"
require_relative "./person_handler.rb"
require_relative "./location_handler.rb"
require_relative "./publisher_handler.rb"

class PublicationHandler < EntryHandler
  
  def initialize(args)
    super
    @location_index = args[:location_index]

    @role_mappings = {
      'aut' => 'author' ,
      'edt' => 'editor'
    }
  end

  def serialize
    super

    @json.merge!({
      "@type" => "CreativeWork" ,
      "name" => @resource['title']
    })
    if (mapping = get_mapping)
      # we have a DNB-based mapping, so get data from there
      role = mapping['role']
      if (person = get_person(mapping))
        @json.merge!({
          @role_mappings[role] => person
        })
      end
    else
      # we don't have a DNB-based mapping, so get data from original list
      if (author = get_list_author)
        @json[:author] = author
      end
    end
    if (publication_enhanced = get_publication_enhanced)
      if (publisher = get_publisher(publication_enhanced))
        @json.merge!({
          "publisher" => publisher
        })
        if publisher['provenance'].eql?(@conf[:provenances][:dnb])
          @json['datePublished'] = publication_enhanced['issued']
        elsif publisher['provenance'].eql?(@conf[:provenances][:orig])
          @json['datePublished'] = @resource['first_edition_publication_year']
        end
      end
    end
    return @json
  end

  def get_publication_enhanced
    row_id = @resource['row']
    return @publications_by_row[row_id]
  end

  def get_mapping
    if (publication_enhanced = get_publication_enhanced)
      return @mappings[publication_enhanced['id']]
    else
      return nil
    end
  end

  def get_list_author
    if (firstname = @resource['author_firstname'] && !is_null?(firstname))
      if (lastname = @resource['author_lastname'])
        author = {
          "@type" => "Person" ,
          :name => "#{firstname} #{lastname}" ,
          :givenName => firstname ,
          :familyName => lastname
        }
        if (same_as = @resource['author_gnd'])
          unless is_null?(same_as)
            same_as = URI.extract(same_as)
            if same_as.count > 0
              author['sameAs'] = [] unless author['sameAs']
              author['sameAs'].concat(same_as) 
            end 
          end
        end
        return author
      end
    end
    return nil
  end

  def get_person(mapping)
    person_id = mapping['person_id']
    person = @people[person_id]
    person_handler = PersonHandler.new({ 
      :resource => person ,
      :conf => @conf
    })
    return person_handler.serialize
  end

  def get_publisher(publication_enhanced)
    publisher_resource = {
      :list_resource => @resource ,
      :enhanced_resource => publication_enhanced
    }
    handler = PublisherHandler.new({ 
      :resource => publisher_resource , 
      :conf => @conf ,
      :location_index => @location_index
    })
    return handler.serialize
  end

end