class Product < ActiveRecord::Base
  validates :title, :user_id, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  has_many :placements
  has_many :orders, through: :placements
end
