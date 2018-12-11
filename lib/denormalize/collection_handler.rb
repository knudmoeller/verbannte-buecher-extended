require_relative "./entry_handler.rb"

class CollectionHandler < EntryHandler
  
  def serialize
    super
    build_collection(@resource).each do |publication|
      @json['hasPart'] = [] unless @json['hasPart']
      @json['hasPart'] << publication
    end
    @json.merge!({
      "@type" => "Collection" ,
      "author" => build_author ,
      "name" => build_title
    })
    return @json
  end
  
  def build_author
    author = {
      "@type" => "Person" ,
      "name" => build_author_name
    }
  end

  def build_author_name
    given_name = @resource['author_firstname']
    family_name = @resource['author_lastname']
    return "#{given_name} #{family_name}"
  end

  def build_title
    given_name = @resource['author_firstname']
    family_name = @resource['author_lastname']
    return "#{family_name}, #{given_name}: #{@resource['title']}"
  end

  def build_collection(resource)
    publications = []
    if (author_gnd = @resource['author_gnd'])
      if (person = @people_by_gnd[author_gnd])
        if (publication_ids = @publications_by_author[person['id']])
          publication_ids.each do |publication_id|
            publications << build_publication(@publications[publication_id])
          end
        end
      end
    end
    return publications
  end

  def build_publication(publication)
    json = {
      "@type" => "CreativeWork" ,
      "name" => publication['title']
    }
    unless publication['issued'].eql?("NULL")
      json['datePublished'] = publication['issued'] 
    end
    if publication['gnd'].start_with?("http")
      json['sameAs'] = [ publication['gnd'].strip ]
    end
    return json
  end

end