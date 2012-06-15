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
  def setup
    @all_elements = [
      Hash['name'=>'id','type'=>'text','display_name'=>'Boletin','order'=>0],
      Hash['name'=>'title','type'=>'false','display_name'=>'Titulo','order'=>1],
      Hash['name'=>'summary','type'=>'false','display_name'=>'Resumen','order'=>2],
      Hash['name'=>'tags','type'=>'tag','display_name'=>'Tags','order'=>3],
      Hash['name'=>'matters','type'=>'tag','display_name'=>'Materias','order'=>4],
      Hash['name'=>'stage','type'=>'text','display_name'=>'Etapa','order'=>5],
      Hash['name'=>'creation_date','type'=>'date','display_name'=>'Fecha de Creación','order'=>6],
      Hash['name'=>'publish_date','type'=>'date','display_name'=>'Fecha Publicación','order'=>7],
      Hash['name'=>'authors','type'=>'text','display_name'=>'Autores','order'=>8],
      Hash['name'=>'origin_chamber','type'=>'text','display_name'=>'Cámara de origen','order'=>9],
      Hash['name'=>'table_history','order'=>10]
    ]
  end

  def test_get_fields_with_metadata_hashed
  	#using models.rb 
  	#TODO: Think of a way to have a models_test.rb and use it instead
    get '/fields?bills'
    assert last_response.ok?

  
    actual_result = JSON.parse(last_response.body)
    assert_equal actual_result.count, @all_elements.count
    assert actual_result.include? @all_elements[0]
    assert actual_result.include? @all_elements[1]
    assert actual_result.include? @all_elements[2]
    assert actual_result.include? @all_elements[3]
    assert actual_result.include? @all_elements[4]
    assert actual_result.include? @all_elements[5]
    assert actual_result.include? @all_elements[6]
    assert actual_result.include? @all_elements[7]
    assert actual_result.include? @all_elements[8]
    assert actual_result.include? @all_elements[9]
  end
  def test_get_fields_ordered
    get '/fields?bills'
    actual_result = JSON.parse(last_response.body)
    assert_equal actual_result, @all_elements
  end
end