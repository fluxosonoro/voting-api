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
  field :id, :class => String               # Bulletin Number without dots
  field :title, :class => String
  field :summary, :class => String
  field :tags, :class => Array
  field :matters, :class => Array
  field :stage, :class => String            # Current Stage
  field :creation_date, :type => DateTime
  field :publish_date, :type => DateTime
  field :authors, :class => Array
  field :origin_chamber, :class => String
  field :table_history, :class => Array

  # Indexes
  index :id, :unique => true
  index :tags
  index :matters
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
