# coding: utf-8
require 'sunspot_mongoid'
Mongoid.logger = nil

class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Relations
  embeds_many :events, :autosave => true
#  add reference to tables (probably a table array)
#  belongs_to :table  

  # Fields
  field :id, :class => String ,:meta => ['display_name'=>'Boletin', 'link_to_detail'=>true, 'type'=>'text', 'should_be_shown_in_list'=>true]
  field :title, :class => String ,:meta => ['type'=>'false','display_name'=>'Titulo', 'should_be_shown_in_list'=>true]
  field :summary, :class => String ,:meta => ['type'=>'false','display_name'=>'Resumen', 'should_be_shown_in_list'=>false]
  field :tags, :class => Array ,:meta => ['type'=>'tag','display_name'=>'Tags', 'should_be_shown_in_list'=>false]
  field :matters, :class => Array ,:meta => ['type'=>'tag','display_name'=>'Materias', 'should_be_shown_in_list'=>false]
  field :stage, :class => String ,:meta => ['type'=>'text','display_name'=>'Etapa', 'should_be_shown_in_list'=>true]            # Current Stage
  field :creation_date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha de Creación', 'should_be_shown_in_list'=>true]
  field :publish_date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha Publicación', 'should_be_shown_in_list'=>true]
  field :authors, :class => Array ,:meta => ['type'=>'text','display_name'=>'Autores', 'should_be_shown_in_list'=>false]
  field :origin_chamber, :class => String ,:meta => ['type'=>'text','display_name'=>'Cámara de origen', 'should_be_shown_in_list'=>false]
  field :current_urgency, :class => String ,:meta => ['type'=>'text','display_name'=>'Urgencia', 'should_be_shown_in_list'=>false]
  field :table_history, :class => Array ,:meta => ['should_be_shown_in_list'=>false]
  field :link_law, :class => Array ,:meta => ['type'=>'text','display_name'=>'Link a la ley', 'should_be_shown_in_list'=>false]

  # Indexes
  index :id, :unique => true
  index :tags
  index :matters

  def get_metadata
    return {
      'title'=>self.title
    }
  end
  
  include Sunspot::Mongoid
#  searchable :auto_remove => true do
  searchable do
    string :id#, :stored => true
    text :title#, :stored => true
    text :summary
    text :stage
    time :creation_date
    time :publish_date
    text :origin_chamber
    text :current_urgency
  end
end

class Table
  include Mongoid::Document
  include Mongoid::Timestamps

  
  # Relations
  has_many :bills, :autosave => true
  #Fields
  field :id, :class => String
  field :date, :type => Date
  field :chamber, :class => String
  field :legislature, :class => String
  field :session, :class => String

# Indexes
  index :id, :unique => true
end

class Event
  include Mongoid::Document
  include Mongoid::Timestamps


  has_many :event_descriptions

  # Fields
  field :start_date, :type => Date
  field :end_date, :type => Date
  field :type, :class => String
  # Relations
  embedded_in :bill
end

class EventDescription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, :class=> String
  field :value

end

# record information about every API request
class Hit
  include Mongoid::Document

  index :created_at
  index :method
  index :sections
  index :user_agent
end
