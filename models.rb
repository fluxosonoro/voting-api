# coding: utf-8
require 'sunspot_mongoid'

class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Relations
  has_many :stage_historys
  has_many :bill_external_references
  has_many :tables

  # Fields
  field :id, :class => String ,:meta => ['display_name'=>'Boletin', 'link_to_detail'=>true, 'type'=>'text', 'order'=>0, 'should_be_shown_in_list'=>true]
  field :title, :class => String ,:meta => ['type'=>'false','display_name'=>'Titulo', 'order'=>1, 'should_be_shown_in_list'=>true]
  field :summary, :class => String ,:meta => ['type'=>'false','display_name'=>'Resumen', 'order'=>2, 'should_be_shown_in_list'=>false]
  field :tags, :class => Array ,:meta => ['type'=>'tag','display_name'=>'Tags', 'order'=>3, 'should_be_shown_in_list'=>false]
  field :matters, :class => Array ,:meta => ['type'=>'tag','display_name'=>'Materias', 'order'=>4, 'should_be_shown_in_list'=>false]
  field :stage, :class => String ,:meta => ['type'=>'text','display_name'=>'Etapa', 'order'=>5, 'should_be_shown_in_list'=>true]            # Current Stage
  field :creation_date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha de Creación', 'order'=>6, 'should_be_shown_in_list'=>true]
  field :publish_date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha Publicación', 'order'=>7, 'should_be_shown_in_list'=>true]
  field :authors, :class => Array ,:meta => ['type'=>'text','display_name'=>'Autores', 'order'=>8, 'should_be_shown_in_list'=>false]
  field :origin_chamber, :class => String ,:meta => ['type'=>'text','display_name'=>'Cámara de origen', 'order'=>9, 'should_be_shown_in_list'=>false]
  field :table_history, :class => Array ,:meta => ['order'=>10, 'should_be_shown_in_list'=>false]

  # Indexes
  index :id, :unique => true
  index :tags
  index :matters

  include Sunspot::Mongoid
  searchable do
    text :id
    text :title
    text :summary
    text :stage
    text :origin_chamber
  end

end

	class Table
  include Mongoid::Document
  include Mongoid::Timestamps

  #Fields
  field :id, :class => String
  field :date, :class => DateTime
  field :chamber, :class => String
  field :legislature, :class => String
  field :session, :class => String

# Indexes
  index :id, :unique => true

  # Relations
  belongs_to :bill
end

class BillExternalReference
  include Mongoid::Document
  include Mongoid::Timestamps
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Fields
  field :id, :class => Integer
  field :name, :class => String
  field :url, :class => String
  field :date, :class => DateTime

  # Indexes
  index :id, :unique => true

  # Relations
  belongs_to :bill
end

class StageHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Fields
  field :id, :class => Integer
  field :stage_name, :class => String
  field :start_date, :class => DateTime
  field :end_date, :class => DateTime

  # Indexes
  index :id, :unique => true

  # Relations
  belongs_to :bill
end

# record information about every API request
class Hit
  include Mongoid::Document

  index :created_at
  index :method
  index :sections
  index :user_agent
end
