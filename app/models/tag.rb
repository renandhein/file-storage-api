class Tag < ApplicationRecord
  has_and_belongs_to_many :stored_files

  validates :name, length: {maximum: 100}, format: {with: /\A^[^-+\s]*$\z/, message: :contains_invalid_characters}
end
