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
    let!(:first_product)  { create(:product, price: 50.0) }
    let!(:second_product) { create(:product, price: 100.0) }
    let!(:products_list)  { [first_product, second_product] }
    let!(:order)          { create(:order, product_ids: products_list.map(&:id)) }
    let(:expected_total)  { products_list.map(&:price).sum }

    it 'returns the total amount to pay for the products' do
      expect(order.total).to eq expected_total
    end
  end
end
