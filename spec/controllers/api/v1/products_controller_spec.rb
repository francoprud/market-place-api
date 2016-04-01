require 'rails_helper'

describe Api::V1::ProductsController do
  describe 'GET #show' do
    let!(:product) { create(:product) }

    before(:each) { get :show, id: product.id }

    it { should respond_with 200 }

    it 'returns the information about the product on a hash' do
      expect(json_response[:title]).to eq product.title
    end

    it 'returns the user as an embedded model' do
      expect(json_response[:user][:email]).to eq product.user.email
    end
  end

  describe 'GET #index' do
    let!(:products) { create_list(:product, 5) }

    before(:each) { get :index }

    it { should respond_with 200 }

    it 'returns 5 products from the database' do
      expect(json_response.count).to eq 5
    end

    it 'returns the user object into each product' do
      json_response.each do |product_response|
        expect(product_response[:user]).to be_present
      end
    end

    context 'when product_ids parameter is sent' do
      let!(:user)          { create(:user) }
      let!(:user_products) { create_list(:product, 3, user: user) }
      let(:product_ids)    { Product.where(user: user).ids }

      before(:each) { get :index, product_ids: product_ids }

      it { should respond_with 200 }

      it 'returns just the products that belong to that user' do
        json_response.each do |product_response|
          expect(product_response[:user][:email]).to eq user.email
        end
      end
    end
  end

  describe 'POST #create' do
    let!(:user) { create(:user) }

    context 'when is successfully created' do
      let(:valid_attrs) do
        {
          title: 'Valid Title',
          price: 100,
          published: true
        }
      end

      before(:each) do
        api_authorization_header user.auth_token
        post :create, user_id: user.id, product: valid_attrs
      end

      it { should respond_with 201 }

      it 'renders the json representation for the product record just created' do
        expect(json_response[:title]).to eq valid_attrs[:title]
      end
    end

    context 'when is not created' do
      context 'because of url mismatch' do
        let(:valid_attrs) do
          {
            title: 'Valid Title',
            price: 100,
            published: true
          }
        end

        before(:each) do
          api_authorization_header user.auth_token
          post :create, user_id: 'invalid', product: valid_attrs
        end

        it { should respond_with 400 }

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the product could not be created' do
          expect(json_response[:errors]).to include 'Url mismatch'
        end
      end

      context 'because of invalid attributes' do
        # Missing title
        let(:invalid_attrs) do
          {
            price: 100,
            published: true
          }
        end

        before(:each) do
          api_authorization_header user.auth_token
          post :create, user_id: user.id, product: invalid_attrs
        end

        it { should respond_with 422 }

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the product could not be created' do
          expect(json_response[:errors][:title]).to include "can't be blank"
        end
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let!(:user)    { create(:user) }
    let!(:product) { create(:product, user: user) }

    context 'when is successfully updated' do
      let(:valid_attrs) {{ title: 'Valid title' }}

      before(:each) do
        api_authorization_header user.auth_token
        patch :update, user_id: user.id, id: product.id, product: valid_attrs
      end

      it { should respond_with 200 }

      it 'renders the json representation for the updated product' do
        expect(json_response[:title]).to eq valid_attrs[:title]
      end
    end

    context 'when is not updated' do
      context 'because of url mismatch' do
        let(:valid_attrs) {{ title: 'Valid title' }}

        before(:each) { api_authorization_header user.auth_token }

        context 'when user_id is not valid' do
          before(:each) { patch :update, user_id: 'invalid', id: product.id, product: valid_attrs }

          it { should respond_with 400 }

          it 'renders an error json' do
            expect(json_response).to have_key(:errors)
          end

          it 'renders the json error on why the product could not be updated' do
            expect(json_response[:errors]).to include 'Url mismatch'
          end
        end

        context 'when product_id is not valid' do
          before(:each) { patch :update, user_id: user.id, id: 'invalid', product: valid_attrs }

          it { should respond_with 404 }

          it 'renders an error json' do
            expect(json_response).to have_key(:errors)
          end

          it 'renders the json error on why the product could not be updated' do
            expect(json_response[:errors]).to include 'product not found or user not owner'
          end
        end
      end

      context 'because of invalid attributes' do
        let(:invalid_attrs) {{ price: 'invalid_price' }}

        before(:each) do
          api_authorization_header user.auth_token
          patch :update, user_id: user.id, id: product.id, product: invalid_attrs
        end

        it { should respond_with 422 }

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the product could not be created' do
          expect(json_response[:errors][:price]).to include 'is not a number'
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user)    { create(:user) }
    let!(:product) { create(:product, user: user) }

    before(:each) { api_authorization_header user.auth_token }

    context 'when is deleted' do
      before(:each) { delete :destroy, user_id: user.id, id: product.id }

      it { should respond_with 204 }

      it 'reduces the amount of products in database' do
        expect(Product.count).to eq 0
      end
    end

    context 'when is not deleted' do
      context 'becuase product could not be found' do
        before(:each) { delete :destroy, user_id: user.id, id: 'invalid' }

        it { should respond_with 404 }

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the product could not be deleted' do
          expect(json_response[:errors]).to include 'product not found or user not owner'
        end
      end
    end
  end
end
