require 'json'
require 'pp'
require 'nokogiri'
require 'csv'
require 'uri'

require_relative './publication_handler.rb'
require_relative './collection_handler.rb'

class Denormalizer

  attr_reader :list, :people, :publications, :publications_by_row, :mappings

  def initialize(args)
    @conf = args[:conf]
  end

  def read_sources
    puts "reading list ..."
    @list = Hash.new
    list_path = File.join(@conf[:data_folder], "source", @conf[:sources][:list])
    document = Nokogiri::XML(File.read(list_path))
    document.css('custom > row').each do |row|
      id = row.css('id').text.strip
      @list[id] = Hash[row.elements.map { |element| [ element.name, element.text ] }]
    end

    puts "reading publications ..."
    @publications = Hash.new
    @publications_by_row = Hash.new
    publication_path = File.join(@conf[:data_folder], "source", @conf[:sources][:publication])
    CSV.foreach(publication_path, { :headers => true }) do |row|
      id = row['id']
      row_id = row['list_row']
      @publications[id] = row
      @publications_by_row[row_id] = row
    end

    puts "reading people ..."
    @people = Hash.new
    @people_by_gnd = Hash.new
    people_path = File.join(@conf[:data_folder], "source", @conf[:sources][:people])
    CSV.foreach(people_path, { :headers => true }) do |row|
      id = row['id']
      @people[id] = row.to_hash
      if (gnd = row['gnd'])
        @people_by_gnd[gnd] = row.to_hash
      end
    end

    puts "reading mapping ..."
    @mappings = Hash.new
    @publications_by_author = Hash.new
    mapping_path = File.join(@conf[:data_folder], "source", @conf[:sources][:mapping])
    CSV.foreach(mapping_path, { :headers => true }) do |row|
      publication_id = row['publication_id']
      @mappings[publication_id] = row
      if (row['role'].eql?("aut"))
        person_id = row['person_id']
        @publications_by_author[person_id] = [] unless @publications_by_author[person_id]
        @publications_by_author[person_id] << publication_id
      end
    end

    puts "index locations ..."
    @location_index = {}
    @publications.each do |id, publication|
      if (location = publication['place_of_publication'])
        if (sameAs = publication['geonames_place_of_publication'])
          @location_index[location] = sameAs
        end
      end
    end

    puts "reading publisher corrections ..."
    corrections_path = File.join(@conf[:data_folder], "source", "publisher_corrections.json")
    corrections = JSON.parse(File.read(corrections_path))
    @conf[:publisher_corrections] = corrections
    
    @handler_args = {
      :conf => @conf ,
      :people => @people ,
      :people_by_gnd => @people_by_gnd ,
      :publications => @publications ,
      :publications_by_row => @publications_by_row ,
      :mappings => @mappings ,
      :publications_by_author => @publications_by_author ,
      :location_index => @location_index
    }

  end
  
  def categorize_list_entry(entry)
    if (entry['complete_works'] == "1")
      return :complete_works
    elsif (entry['complete_works'] == "3")
      return :complete_works_by_about
    elsif (entry['complete_workds'] == "4")
      return :complete_works_restricted
    elsif (entry['title_gnd'].eql?("NULL") && entry['author_gnd'].eql?("NULL"))
      return :publisher
    elsif (!entry['title_gnd'].eql?("NULL"))
      return :publication
    end
    return nil
  end

  def force_array(object)
    object.is_a?(Array) ? object : [ object ]
  end

  def create_id(id, namespace)
    id = id.split(",").first
    
  end

  def serialize

    puts "serializing output ..."

    list_elements = []
    # Hash[@list.to_a[0..49]].each do |id, entry|
    @list.each do |id, entry|
      if (entry_json = handle_entry(entry))
        list_elements << entry_json
      end
    end

    terms = {}
    @conf[:vocabs].values.each { |vocab| terms.merge!(vocab) }

    json =  {
      "@context" => [
        "http://schema.org" ,
        terms
      ] ,
      "@type" => [ "ItemList", "CreativeWork" ] ,
      "name" => "List der Verbannten Bücher" ,
      "itemListOrder" => "http://schema.org/ItemListOrderAscending",
      "numberOfItems" => @list.count ,
      "itemListElement" => list_elements ,
      "description" => "This list is an extended version of the original 'Liste der Verbannten Bücher'." ,
      "url" => "https://github.com/knudmoeller/verbannte-buecher-extended" ,
      "license" => "https://creativecommons.org/licenses/by/3.0/de/"
    }

    out_path = File.join(@conf[:data_folder], "target", @conf[:output_json])
    File.open(out_path, "w") do |file|
      file.puts (JSON.pretty_generate(json))
    end

  end

  def handle_entry(entry)
    json = nil
    category = categorize_list_entry(entry)
    @handler_args[:resource] = entry
    case category
    when :publication
      entry_handler = PublicationHandler.new(@handler_args)
    when :complete_works
      entry_handler = CollectionHandler.new(@handler_args)
    end
    json = entry_handler.serialize if entry_handler
    return json
  end
  
end
