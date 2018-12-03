# coding: utf-8

require_relative '../../lib/denormalize/denormalizer.rb'
require_relative '../../conf/conf.rb'
require 'minitest/autorun'

class TestDenormalizer < MiniTest::Unit::TestCase
  
  def setup
    conf = Conf.conf
    conf[:data_folder] = File.join(File.dirname(__FILE__), "..", "data")

    @denormalizer = Denormalizer.new({
      :conf => conf
    })
    @denormalizer.read_sources
  end


  def test_publication
    entry = @denormalizer.list['2']
    entry_json = @denormalizer.handle_entry(entry)

    assert_equal("CreativeWork", entry_json['@type'])
    assert_equal("Frauenleiden", entry_json['name'])
    # more assertions
  end

  def test_no_author_name
    # {
    #   "title": "Erinnerungen der Miss Barbara",
    #   "ssFlag": true,
    #   "authorFirstname": "",
    #   "authorLastname": "",
    #   "firstEditionPublisher": "Kuriosa-Verl.",
    #   "firstEditionPublicationYear": " 1925",
    #   "firstEditionPublicationPlace": " Paris",
    #   "secondEditionPublisher": "Kuriosa-Verl.",
    #   "secondEditionPublicationYear": " 1925",
    #   "secondEditionPublicationPlace": " Paris",
    #   "additionalInfos": "",
    #   "pageNumberInOCRDocument": 33,
    #   "ocrResult": "Erinnerungen der Miss Barbara. Paris: Kuriosa-Verl. 1925.",
    #   "correctionsAfter1938": null
    # }
    entry = @denormalizer.list['5887']
    entry_json = @denormalizer.handle_entry(entry)
    
    assert_equal("CreativeWork", entry_json['@type'])
    assert_nil(entry_json['author'])

  end

end