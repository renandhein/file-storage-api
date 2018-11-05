class StoredFile < ApplicationRecord
  validates :name, length: {maximum: 100}
end
