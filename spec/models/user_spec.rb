require 'rails_helper'

describe User do
  let!(:user) { create(:user) }

  subject { user }

  it { should be_valid }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:auth_token) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('test@domain.com').for(:email) }

  it { should have_many(:products) }
  it { should have_many(:orders) }

  describe '#generate_authentication_token!' do
    let(:unique_token) { 'auniquetoken123' }
    let!(:other_user)  { create(:user, auth_token: unique_token) }

    it 'generates a unique token' do
      allow(Devise).to receive(:friendly_token).and_return(unique_token)
      user.generate_authentication_token!
      expect(user.auth_token).to eq unique_token
    end

    it 'generates another token when one already has been taken' do
      user.generate_authentication_token!
      expect(user.auth_token).not_to eq other_user.auth_token
    end
  end

  describe '#products association' do
    let!(:products)       { create_list(:product, 3, user: user) }
    let(:products_amount) { Product.count }

    context 'when destroying a user' do
      before(:each) { user.destroy }

      it 'destroys the products that were associated with that user' do
        expect(Product.count).to eq 0
      end
    end
  end
end
