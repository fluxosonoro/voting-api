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

  def test_get_fields_with_metadata_hashed
  	#using models.rb 
  	#TODO: Think of a way to have a models_test.rb and use it instead
    get '/fields?bills'
    assert last_response.ok?

    all_elements = [
      Hash['name'=>'id','type'=>'text','display_name'=>'Boletin'],
      Hash['name'=>'title','type'=>'false','display_name'=>'Titulo'],
      Hash['name'=>'summary','type'=>'false','display_name'=>'Resumen'],
      Hash['name'=>'tags','type'=>'tag','display_name'=>'Tags'],
      Hash['name'=>'matters','type'=>'tag','display_name'=>'Materias'],
      Hash['name'=>'stage','type'=>'text','display_name'=>'Etapa'],
      Hash['name'=>'creation_date','type'=>'date','display_name'=>'Fecha de Creación'],
      Hash['name'=>'publish_date','type'=>'date','display_name'=>'Fecha Publicación'],
      Hash['name'=>'authors','type'=>'text','display_name'=>'Autores'],
      Hash['name'=>'origin_chamber','type'=>'text','display_name'=>'Cámara de origen'],
      Hash['name'=>'table_history']
    ]

    first_element = all_elements[0]
    actual_result = JSON.parse(last_response.body)
    assert_equal actual_result.count, all_elements.count
    assert actual_result.include? first_element
    assert_equal all_elements, actual_result
  end
end