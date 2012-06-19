# coding: utf-8
require "rubygems"
require 'api'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class FieldsWithMetadataTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  def test_get_models_without_any_empty_strings
  	get '/models'
  	assert last_response.ok?
  	actual_result = JSON.parse(last_response.body)
  	expected_result = [
  		"tables", "stage_histories", "bill_external_references", "hits", "bills"
  	]
  	assert actual_result.include? expected_result[0]
  	assert actual_result.include? expected_result[1]
  	assert actual_result.include? expected_result[2]
  	assert actual_result.include? expected_result[3]
  	assert actual_result.include? expected_result[4]
  	assert_equal expected_result.count, actual_result.count
  end
end