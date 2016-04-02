require 'rails_helper'

describe Order do
  let!(:product) { create(:product) }
  let!(:order) { create(:order, product_ids: [product.id]) }

  subject { order }

  it { should respond_to(:total) }
  it { should respond_to(:user_id) }

  it { should validate_presence_of(:user_id) }

  it { should belong_to(:user) }
  it { should have_many(:placements) }
  it { should have_many(:products).through(:placements) }

  describe '#set_total!' do
    let!(:first_product)    { create(:product, price: 50.0, quantity: 5) }
    let!(:second_product)   { create(:product, price: 100.0, quantity: 4) }
    let!(:first_placement)  { build(:placement, product: first_product, quantity: 1) }
    let!(:second_placement) { build(:placement, product: second_product, quantity: 2) }
    let!(:order)            { build(:order, placements: [first_placement, second_placement]) }
    let(:expected_total)    { first_product.price * first_placement.quantity + second_product.price * second_placement.quantity }

    it 'returns the total amount to pay for the products' do
      expect(order.set_total!).to eq expected_total
    end
  end

  describe '#build_placements_with_product_ids_and_quantities' do
    let!(:first_product)  { create(:product, price: 50.0) }
    let!(:second_product) { create(:product, price: 100.0) }
    let!(:order_quantities) { [[first_product.id, 2], [second_product.id, 3]] }

    it 'builds 2 placements for the order' do
      expect { order.build_placements_with_product_ids_and_quantities(order_quantities) }.to change { order.placements.size }.from(1).to(3)
    end
  end

  describe '#valid?' do
    let!(:first_product)    { create(:product, price: 100, quantity: 5) }
    let!(:second_product)   { create(:product, price: 100, quantity: 10) }
    let!(:first_placement)  { build(:placement, product: first_product, quantity: 3) }
    let!(:second_placement) { build(:placement, product: second_product, quantity: 15) }
    let!(:order)            { build(:order, placements: [first_placement, second_placement]) }

    it 'becomes invalid due to insufficient products' do
      expect(order).to_not be_valid
    end
  end
end
