#!/usr/bin/env ruby
# coding: utf-8

require './config/environment'

# for example: [Parlamentario, Proyecto] => "parlamentarios|proyectos"
endpoints = models.map do |model|
  model.to_s.underscore.pluralize
end.join "|"


pattern = /^\/(#{endpoints})/

one_pattern = /^\/detail\/(#{endpoints})/

# HTTP GET
get pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize

  # which fields to request on each document
  fields = fields_for(params)

  # fields to filter
  conditions = conditions_for(model, params)
  
  # fields to filter for solr search
  solr_conditions = solr_conditions_for(model, params)

  # how to order the results
  order = order_for(model, params)

  # how to paginate the results
  pagination = pagination_for(params)

  # decide whether this is an explanation response, or a normal response
  if params[:explain] == 'true'
    results = explain_for(model, conditions, fields, order, pagination)
  else
#    results = results_for(model, conditions, fields, order, pagination)
    results = solr_results_for(model, solr_conditions, fields, order, pagination)
  end

  # serialize to JSON and return it
  response['Content-Type'] = 'application/json'
  json = results.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

get one_pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize
  conditions = conditions_for(model, params)
  the_one = one_result_for(model, conditions)

  response['Content-Type'] =  'application/json'
  json = the_one.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# HTTP POST
post pattern do
    # for example: "foos" => Foo
    model = params[:captures][0].singularize.camelize.constantize

    # fields to filter
    conditions = conditions_for(model, params)

    # the only valid condition to delete a document is by id, the rest are ommited
    conditions.delete_if{|key, value| key != 'id' }

    if params.include?('id')
      results = update_for(model, conditions, params)
      if results
        status 200
      else
        status 501
        results = {'code' => 4, 'message' => 'The document couldn\'t be updated'}
      end
    else
      status 501
      results = {'code' => 2, 'message' => 'id is required to perform this action'}
    end

    # serialize to JSON and return it
    response['Content-Type'] = 'application/json'
    json = results.to_json
    params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# HTTP PUT
put pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize

  if params.include?('id')
    results = insert_for(model, params)
    if results
      status 201
    else
      status 501
      results = {'code' => 1, 'message' => 'The document couldn\'t be created'}
    end
  else
    status 501
    results = {'code' => 2, 'message' => 'id is required to perform this action'}
  end

  # serialize to JSON and return it
  response['Content-Type'] = 'application/json'
  json = results.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# HTTP DELETE
delete pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize

  # fields to filter
  conditions = conditions_for(model, params)

  # the only valid condition to delete a document is by id, the rest are ommited
  conditions.delete_if{|key, value| key != 'id' }

  if params.include?('id')
    results = delete_for(model, conditions)
    results = {'value' => results}
    if results
      status 200
    else
      status 501
      results = {'code' => 3, 'message' => 'The document couldn\'t be deleted'}
    end
  else
    status 501
    results = {'code' => 2, 'message' => 'id is required to perform this action'}
  end

  # serialize to JSON and return it
  response['Content-Type'] = 'application/json'
  json = results.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# log all hits in the database
after pattern do
  Hit.create!(
    :method => params[:captures][0],
    :query_hash => remove_dots(request.env['rack.request.query_hash']).to_hash,
    :user_agent => request.env['HTTP_USER_AGENT'],
    :created_at => Time.now.utc
  )
end

helpers do

  # Gets the params
  def fields_for(params)
    if params[:fields].present?
      params[:fields].split(',').uniq
    end
  end

  # Gets the restrictions for data fetching from the params
  def conditions_for(model, params)
    conditions = {}

    params.each do |key, value|
      if !magic_fields.include?(key.to_sym) && model.fields.include?(key) && !value.nil?() && value != ""
        if key != 'id'
          conditions[key] = /#{value}/
        else
          conditions[key] = value
        end
      end
    end

    conditions
  end

  # Same things as above method, but params are strings instead of regex
  def solr_conditions_for(model, params)
    conditions = {}

    params.each do |key, value|
      if !magic_fields.include?(key.to_sym) && (model.fields.include?(key) || special_searches.include?(key)) && !value.nil?() && value != ""
        conditions[key] = value
      end
    end

    conditions
  end

  # Gets the order from the params
  def order_for(model, params)
    key = nil
    if params[:sort].present?
      key = params[:sort].to_sym
    else
      key = :_id
    end

    order = nil
    if params[:order].present? and [:desc, :asc].include?(params[:order].downcase.to_sym)
      order = params[:order].downcase.to_sym
    else
      order = :desc
    end

    [[key, order]]
  end

  # Returns attributes of a document, excluding mongo internal fields
  def attributes_for(document, fields)
    attributes = document.attributes
    mongo_internals.each {|key| attributes.delete(key) unless (fields || []).include?(key.to_s)}
    attributes
  end

  # Returns queried attributes of a document
  def solr_attributes_for(document, fields)
    attributes = document.attributes
    #deletes mongo internals
    mongo_internals.each {|key| attributes.delete(key) unless (fields || []).include?(key.to_s)}
    #deletes unwanted fields, unless fields == nil
    attributes.each_key {|key| attributes.delete(key) unless (fields || []).include?(key.to_s)} unless fields.nil?
    attributes
  end

  # Deletes documents from the database
  def delete_for(model, conditions)
    criteria = criteria_for(model, conditions)

    documents = criteria.to_a

    # validates if one or more documents were returned
    if documents.size >= 1
      # deletes only the first document
      documents[0].delete
    end
  end

  # Inserts documents into the database
  def insert_for(model, params)
    document = model.new
    params.each do |key, value|
      if !magic_fields.include?(key.to_sym)
        #This is a very ugly code to embed a document inside another one
        if model.relations.include? key
          embeded_document_class = model.relations[key].class_name.constantize
          if model.relations[key].relation.macro == :embeds_many
            value.each do |embeded_key, embeded_value|
              embeded_document =  embeded_document_class.new

              embeded_value.each do |embeded_documents_key, embeded_documents_value|
                begin
                  embeded_document[embeded_documents_key] = embeded_documents_value
                rescue Exception => e



                  #logger.error(e)
                  #logger.error(embeded_documents_value)



                end
                
              end
              eval "document." + key + ".push embeded_document"
            end

          end
	  '''
	  # used when using referenced documents
          if model.relations[key].relation.macro == :references_many
            value.each do |document_id|
              existing_document = embeded_document_class.find(document_id)
              eval "document."+key+".push existing_document"
            end
          end
          '''
          #TODO: avoid the eval sentence and make it posible for other types
          #relation to work

        else
          document[key] = value
        end
      end
        
    end
    

    document.save

    attributes_for(document,  nil)
  end

  # Updates documents in the database
  def update_for(model, conditions, params)
    criteria = criteria_for(model, conditions)
    document = criteria.to_a[0]

    params.each do |key, value|
      if !magic_fields.include?(key.to_sym) && model.fields.include?(key) && key != 'id' && !value.nil?() && value != ""
        if model.fields[key].type == Array
          document[key] = value.split('|')
        else
          document[key] = value
        end
      end
    end

    document.save

    attributes_for(document,  nil)
  end

  def one_result_for(model, conditions)
    criteria = criteria_for(model, conditions, nil, nil, nil)
    if criteria.count == 0
      not_found
    end
    document = criteria.first
    
    hash = attributes_for(document, nil)
    metadata = document.get_metadata

    return {
      :metadata => metadata,
      :data => hash
    }
  end


  # Fetchs database results
  def results_for(model, conditions, fields, order, pagination)
    criteria = criteria_for(model, conditions, fields, order, pagination)
    
    count = criteria.count
    documents = criteria.to_a

    page_total = count/pagination[:per_page]
    if count%pagination[:per_page] > 0
      page_total = page_total + 1
    end

    key = model.to_s.underscore.pluralize

    {
      key => documents.map {|document| attributes_for(document, fields)},
      :count => count,
      :page => {
        :count => documents.size,
        :per_page => pagination[:per_page],
        :page => pagination[:page],
        :total => page_total
      }
    }
  end

  # Explains the query
  def explain_for(model, conditions, fields, order, pagination)
    criteria = criteria_for(model, conditions, fields, order, pagination)

    cursor = criteria.execute
    count = cursor.count

    {
      :conditions => conditions,
      :fields => fields,
      :order => order,
      :explain => cursor.explain,
      :count => count,
      :page => {
        :per_page => pagination[:per_page],
        :page => pagination[:page]
      }
    }
  end
  # Fetchs the documents using conditions and pagination
  def criteria_for(model, conditions, fields = nil, order = nil, pagination = nil)
    if !pagination.nil? && !order.nil?
      skip = pagination[:per_page] * (pagination[:page]-1)
      limit = pagination[:per_page]

      model.where(conditions).only(fields).order_by(order).skip(skip).limit(limit)
    else
      model.where(conditions)
    end
  end

  # Does the pagination
  def pagination_for(params)
    default_per_page = 20
    max_per_page = 500
    max_page = 200000000 # let's keep it realistic

    # rein in per_page to somewhere between 1 and the max
    per_page = (params[:per_page] || default_per_page).to_i
    per_page = default_per_page if per_page <= 0
    per_page = max_per_page if per_page > max_per_page

    # valid page number, please
    page = (params[:page] || 1).to_i
    page = 1 if page <= 0 or page > max_page

    {:per_page => per_page, :page => page}
  end
end


# break out dot-separated fields into sub-documents.
# for example:
# {"title.given_at" => "foo"}
# becomes"
# {"title" => {"given_at" => "foo"}}

# used in storing Hits for analytics.
# this is done because MongoDB cannot store field names with dots in them.

def remove_dots(hash)
  new_hash = {}
  hash.each do |key, value|
    bits = key.split '.'
    break_out new_hash, bits, value
  end
  new_hash
end

def break_out(hash, keys, final_value)
  if keys.size > 1
    first = keys.first
    rest = keys[1..-1]

    # default to on
    hash[first] ||= {}

    break_out hash[first], rest, final_value
  else
    hash[keys.first] = final_value
  end
end

#added by Marcel for the api-client

#model.erb -> {"class" => [fields]}
def get_schema()
  model = {}
  models.each do |the_class|
    fields = []
    the_fields = the_class.fields
    p the_fields
    the_fields.each do |field, value|
      if !mongo_internals.include? field
        the_field = Hash['name'=>field]
        if !value.options[:meta].nil? and value.options[:meta].count > 0
          the_field = the_field.merge(value.options[:meta][0])
        end
        fields.push(the_field)
      end
    end
    model.store(the_class.name.strip.underscore.pluralize,fields)
  end
  return model
end

def get_models()
  schema = get_schema
  schema.keys
end

def get_fields(model)
  schema = get_schema
  schema[model]
end

get '/schema' do
  response['Content-Type'] = 'application/json'
  get_schema.to_json
end

get '/models' do
  response['Content-Type'] = 'application/json'
  get_models.to_json
end

get '/fields' do
  model = params.keys[0]
  response['Content-Type'] = 'application/json'
  get_fields(model).to_json
end

# Added by Marcel for solr search

# returns the results for a solr search
def solr_results_for(model, conditions, fields, order, pagination)

  search = model.solr_search do
    # search over all fields
    if conditions.key?("q")
      fulltext conditions["q"]
      conditions.delete("q")
    #search over specific fields
    end
    conditions.each do |key, value|
      p key.class.name
      text_fields do
        any_of do
          value.split("|").each do |term|
            with(key, term)
          end
        end
      end
    end
    #write it nicer
    p order
    order_by order[0][0], order[0][1] unless order[0][0] == :_id
    paginate :page => pagination[:page], :per_page => pagination[:per_page]
  end

  key = model.to_s.underscore.pluralize
  hits = search.hits
  results = search.results
  hits_array = search.hits.map {|bill| solr_attributes_for(bill.result, fields) unless bill.result.nil?}
#  hits_array.delete_if {|bill| bill.nil?}

  {
    key => hits_array,
#    key => search.each_hit_with_result {|bill| bill[0].result.attributes},
    :count => search.total,
    :page => {
      :count => hits.count,
      :per_page => pagination[:per_page],
      :page => pagination[:page],
      :total => hits.total_pages
    }
  }
end

# All the methods below are only used for testing

#commented to avoid insertions on real database
get '/insert' do
  #model = params.to_s.singularize.camelize.constantize
  #document = model.new
#  document = Bill.new
#  document.title = 'alpha testing'
#  document.save
#  document.attributes.to_json
end

get '/search' do
  search_for = params.to_s
  search = Bill.solr_search do
    fulltext search_for
#    keywords 'ley' do
#      fields(:title)
#    end
  end

  p "<search>"
  p search
  p "</search>"
  
  results = ''
  search.each_hit_with_result do |hit, post|
    results += post.attributes.to_json
  end
  results
end

get '/reindex' do
  Sunspot.remove_all!(Bill)
  Sunspot.index!(Bill.all)
end

get '/' do
  p 'This is an example query
<br>
<a href=http://api.ciudadanointeligente.cl/billit/cl/bills?q=deporte&stage=terminada%7Carchivado&per_page=5&page=2&fields=id,title&sort=creation_date&order=asc>http://api.ciudadanointeligente.cl/billit/cl/bills?q=deporte&stage=terminada%7Carchivado&per_page=5&page=2&fields=id,title&sort=creation_date&order=asc</a>
<br><br>
    "bills?" is the model in which the query is performed
<br>
    "q=deporte" is a query over all the serchable fields
<br>
    "stage=terminada|archivado" is a query on the field "stage" for any of the terms "terminada" or "archivado"
<br>
    "per_page=5" defines the amount of results per page
<br>
    "page=2" is the page number
<br>
    "fields=id,title" are the returned fields
<br>
    "sort=creation_date" is the field by which the query is ordered
<br>
    "order=asc" is the order type ("asc" o "desc")
<br>

(notice "deportes" also matches "DEPORTISTAS", "Deporte", "deportivos", etc. thanks to solr)
<br><br>
These are urls for displaying the data structure
<br>
<a href=http://api.ciudadanointeligente.cl/billit/cl/schema>http://api.ciudadanointeligente.cl/billit/cl/schema</a>
<br>
<a href=http://api.ciudadanointeligente.cl/billit/cl/models>http://api.ciudadanointeligente.cl/billit/cl/models</a>
<br>
<a href=http://api.ciudadanointeligente.cl/billit/cl/fields?bills>http://api.ciudadanointeligente.cl/billit/cl/fields?bills</a>
'
end
