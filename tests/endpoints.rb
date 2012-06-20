# coding: utf-8
require "rubygems"
require 'api'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class EndPointsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  def test_get_one
    get "/detail/bills?id=777"
  	assert last_response.ok?
  end
  def test_get_several
    get "/bills"
    assert last_response.ok?
  end
end