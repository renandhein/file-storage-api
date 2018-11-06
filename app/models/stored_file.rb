class StoredFile < ApplicationRecord
  has_and_belongs_to_many :tags
  
  validates :name, length: {maximum: 100}
end
