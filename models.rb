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
  belongs_to :table
  

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
  field :current_urgency, :class => String ,:meta => ['type'=>'text','display_name'=>'Urgencia', 'order'=>10, 'should_be_shown_in_list'=>false]
  field :table_history, :class => Array ,:meta => ['order'=>11, 'should_be_shown_in_list'=>false]
  field :link_law, :class => Array ,:meta => ['type'=>'text','display_name'=>'Link a la ley', 'order'=>12, 'should_be_shown_in_list'=>false]

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
  searchable :auto_remove => true do
    text :id#, :stored => true
    text :title#, :stored => true
#    text :summary
    text :stage
    text :origin_chamber
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
