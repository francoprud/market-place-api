require 'rails_helper'

describe Api::V1::OrdersController do
  describe 'GET #index' do
    let!(:user)         { create(:user) }
    let!(:orders)       { create_list(:order, 5, user: user) }
    let!(:other_orders) { create_list(:order, 3) }

    before(:each) do
      api_authorization_header user.auth_token
      get :index, user_id: user.id
    end

    it { should respond_with 200 }

    it 'returns 5 order records from the user' do
      expect(json_response.count).to eq 5
    end
  end

  describe 'GET #show' do
    let!(:user)  { create(:user) }
    let!(:order) { create(:order, user: user) }

    context 'when order exists and is from user' do
      before(:each) do
        api_authorization_header user.auth_token
        get :show, user_id: user.id, id: order.id
      end

      it { should respond_with 200 }

      it 'returns the user order record matching the id' do
        expect(json_response[:id]).to eq order.id
      end
    end

    context 'when order does not exists' do
      before(:each) do
        api_authorization_header user.auth_token
        get :show, user_id: user.id, id: 'invalid_id'
      end

      it { should respond_with 404 }

      it 'renders the json error on why the order could not be shown' do
        expect(json_response[:errors]).to include 'order not found or user not owner'
      end
    end

    context 'when the url has a mismatch' do
      before(:each) do
        api_authorization_header user.auth_token
        get :show, user_id: 'invalid_user_id', id: order.id
      end

      it { should respond_with 400 }

      it 'renders an error json' do
        expect(json_response).to have_key(:errors)
      end

      it 'renders the json error on why the product could not be created' do
        expect(json_response[:errors]).to include 'Url mismatch'
      end
    end
  end

  describe 'POST #create' do
    let!(:user)         { create(:user) }
    let!(:products)     { create_list(:product, 3, user: user) }
    let!(:order_params) {{ product_ids: Product.all.ids }}

    context 'when is successfully created' do
      before(:each) do
          api_authorization_header user.auth_token
          post :create, user_id: user.id, order: order_params
        end

      it { should respond_with 201 }

      it 'returns the just user order record' do
        expect(json_response[:id]).to be_present
      end
    end

    context 'when is not created' do
      context 'because of url mismatch' do
        before(:each) do
          api_authorization_header user.auth_token
          post :create, user_id: 'invalid_user_id', order: order_params
        end

        it { should respond_with 400 }

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the product could not be created' do
          expect(json_response[:errors]).to include 'Url mismatch'
        end
      end
    end
  end
end
