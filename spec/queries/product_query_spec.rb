require 'rails_helper'

describe ProductQuery do
  subject { described_class }

  context 'when searching by product_ids' do
    let!(:user)           { create(:user) }
    let!(:user_products)  { create_list(:product, 3, user: user) }
    let!(:other_products) { create_list(:product, 2) }
    let(:product_ids)     { Product.where(user: user).ids }
    let(:query_params)    {{ product_ids: product_ids }}

    it 'returns the products that belong to that user' do
      products = subject.new(query_params).search
      products.each do |product|
        expect(product.user.email).to eq user.email
      end
    end
  end

  context 'when searching by title keyword' do
    let(:title_keyword)      { 'tv' }
    let!(:product_matching1) { create(:product, title: 'Plasma TV') }
    let!(:product_matching2) { create(:product, title: 'TV Flat-Screen') }
    let!(:other_products)    { create_list(:product, 3, title: 'product') }
    let(:query_params)       {{ keyword: title_keyword }}

    it 'returns the 2 products matching' do
      expect(subject.new(query_params).search.count).to eq 2
    end
  end

  context 'when searching by price' do
    let!(:product1)    { create(:product, price: 100.0) }
    let!(:product2)    { create(:product, price: 70.0) }
    let!(:product3)    { create(:product, price: 34.0) }
    let!(:product4)    { create(:product, price: 150.0) }
    let!(:product5)    { create(:product, price: 79.0) }

    context 'and specifying min_price' do
      let(:min_price)    { 80.0 }
      let(:query_params) {{ min_price: min_price }}

      it 'returns the 2 products matching' do
        expect(subject.new(query_params).search.count).to eq 2
      end
    end

    context 'and specifying max_price' do
      let(:max_price)    { 80.0 }
      let(:query_params) {{ max_price: max_price }}

      it 'returns the 2 products matching' do
        expect(subject.new(query_params).search.count).to eq 3
      end
    end
  end
end
