require 'rails_helper'

describe Product do
  let!(:product) { create(:product) }

  subject { product }

  it { should respond_to(:title) }
  it { should respond_to(:price) }
  it { should respond_to(:published) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:quantity) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  it { should belong_to(:user) }
  it { should have_many(:placements) }
  it { should have_many(:orders).through(:placements) }
end
