# coding: utf-8

require_relative '../../lib/denormalize/handler.rb'
require 'minitest/autorun'

class TestHandler < MiniTest::Unit::TestCase

  def setup
    @uri_1 = "http://same.as.org/one"
    @uri_2 = "http://other.resource/data/foo"
    @name = "Hans"
    @handler = Handler.new({
      :resource => {
        "forename" => @name ,
        "gnd" => @uri_1 ,
        "viaf" => @uri_2 ,
        "foo_link" => "NULL"
      }
    })
  end


  def test_add_data
    property_mapping = {
      "givenName" => "forename" ,
    }
    @handler.property_mapping.merge!(property_mapping)
    @handler.add_data("givenName")

    assert_equal(
      @name , 
      @handler.json["givenName"]
    )
  end

  def test_add_same_as
    @handler.add_same_as("gnd")
    @handler.add_same_as("viaf")
    @handler.add_same_as("foo_link")
    assert_equal(
      [ @uri_1, @uri_2 ] ,
      @handler.json['sameAs']
    )
  end

  def test_boolarize
    assert_equal( 
      true ,
      @handler.boolarize("1")
    )
    assert_equal( 
      false ,
      @handler.boolarize("0")
    )
  end

  def test_is_null
    assert_equal(
      true,
      @handler.is_null?(nil)
    )
    assert_equal(
      true,
      @handler.is_null?("NULL")
    )
    assert_equal(
      true,
      @handler.is_null?("")
    )
    assert_equal(
      false,
      @handler.is_null?("whatever")
    )
  end

end
