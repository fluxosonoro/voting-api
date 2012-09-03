# coding: utf-8
require 'sunspot_mongoid'
Mongoid.logger = nil

class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Field Validation
  validates_presence_of :uid
  validates_uniqueness_of :uid

  # Relations
  embeds_many :events, :autosave => true
#  add reference to tables (probably a table array)
#  belongs_to :table  

  # Fields
  field :uid, :type => String ,:meta => ['display_name'=>'Boletin', 'link_to_detail'=>true, 'type'=>'text', 'should_be_shown_in_list'=>true]
  field :title, :type => String ,:meta => ['type'=>'false','display_name'=>'Titulo', 'should_be_shown_in_list'=>true]
  field :summary, :type => String ,:meta => ['type'=>'false','display_name'=>'Resumen', 'should_be_shown_in_list'=>false]
  field :tags, :type => Array ,:meta => ['type'=>'tag','display_name'=>'Tags', 'should_be_shown_in_list'=>false]
  field :matters, :type => Array ,:meta => ['type'=>'tag','display_name'=>'Materias', 'should_be_shown_in_list'=>false]
  field :stage, :type => String ,:meta => ['type'=>'text','display_name'=>'Etapa', 'should_be_shown_in_list'=>true]            # Current Stage
  field :creation_date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha de Creación', 'should_be_shown_in_list'=>true]
  field :publish_date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha Publicación', 'should_be_shown_in_list'=>true]
  field :authors, :type => Array ,:meta => ['type'=>'array','display_name'=>'Autores', 'should_be_shown_in_list'=>false]
  field :origin_chamber, :type => String ,:meta => ['type'=>'text','display_name'=>'Cámara de origen', 'should_be_shown_in_list'=>false]
  field :current_urgency, :type => String ,:meta => ['type'=>'text','display_name'=>'Urgencia', 'should_be_shown_in_list'=>false]
  field :table_history, :type => Array ,:meta => ['should_be_shown_in_list'=>false]
  field :link_law, :type => Array ,:meta => ['type'=>'text','display_name'=>'Link a la ley', 'should_be_shown_in_list'=>false]

  # Indexes
  index :uid, :unique => true
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
    string :uid#, :stored => true
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
  field :uid, :type => String ,:meta => ['display_name'=>'Tabla', 'link_to_detail'=>true, 'type'=>'text', 'should_be_shown_in_list'=>true]
  field :date, :type => DateTime ,:meta => ['type'=>'date','display_name'=>'Fecha', 'should_be_shown_in_list'=>true]
  field :chamber, :type => String ,:meta => ['type'=>'text','display_name'=>'Cámara', 'should_be_shown_in_list'=>true]
  field :legislature, :type => String ,:meta => ['display_name'=>'Legislatura', 'type'=>'text', 'should_be_shown_in_list'=>false]
  field :session, :type => String ,:meta => ['display_name'=>'Sesión', 'type'=>'text', 'should_be_shown_in_list'=>false]
  field :bill_list, :type => Array ,:meta => ['display_name'=>'Boletines','type'=>'array', 'should_be_shown_in_list'=>false]

# Indexes
  index :uid, :unique => true

  def get_metadata
    return {
      'uid'=>self.uid
    }
  end

  include Sunspot::Mongoid
  searchable do
    text :uid
    time :date
    text :chamber
    text :legislature
    text :session
    text :bill_list
  end
end

class Event
  include Mongoid::Document
  include Mongoid::Timestamps


  has_many :event_descriptions

  # Fields
  field :start_date, :type => Date
  field :end_date, :type => Date
  field :type, :type => String
  # Relations
  embedded_in :bill
end

class EventDescription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, :type=> String
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
