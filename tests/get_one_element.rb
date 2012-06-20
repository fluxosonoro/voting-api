# coding: utf-8
require "rubygems"
require 'api'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class GetOneElementTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  def test_get_one
  	get '/detail/bills?id=8029-04'
  	assert last_response.ok?
    actual_bill = JSON.parse(last_response.body)
    expected = {
                'stage'=> "Primer trámite constitucional",
                'origin_chamber'=> "C.Diputados",
                'authors'=> "",
                'creation_date'=> "2011-11-09T05:00:00Z",
                'id'=> "8029-04",
                'title'=> "Modifica Ley General de Enseñanza, estableciendo la obligatoriedad de impartir una hora semanal de educación vial y, normas del tránsito."
                }
    assert_equal expected, actual_bill
  end
  def test_get_one_with_a_callback
    get '/detail/bills?id=8029-04&callback=alert'
    assert last_response.ok?
    answer_to_be_executed = last_response.body
    assert answer_to_be_executed.starts_with? "alert("
    assert answer_to_be_executed.ends_with? ");"
  end
  def test_get_one_that_does_not_exist
    get '/detail/bills?id=8029-05'
    assert last_response.status == 404
  end
end