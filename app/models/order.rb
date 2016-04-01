class Order < ActiveRecord::Base
  validates :user_id, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
end
