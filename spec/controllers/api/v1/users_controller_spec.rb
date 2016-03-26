require 'rails_helper'

describe Api::V1::UsersController do
  before(:each) { request.headers['Accept'] = 'application/vnd.marketplace.v1' }

  describe 'GET #show' do
    let!(:user) { create(:user) }

    before(:each) { get :show, id: user.id, format: :json }

    it { should respond_with 200 }

    it 'returns the information about the user on a hash' do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:email]).to eq user.email
    end
  end

  describe 'POST #create' do
    context 'when is successfully created' do
      let(:valid_user_attrs) do
        {
          email: 'test@email.com',
          password: 'password',
          password_confirmation: 'password'
        }
      end

      before(:each) { post :create, { user: valid_user_attrs }, format: :json }

      it { should respond_with 201 }

      it 'renders the json representation for the user record just created' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq valid_user_attrs[:email]
      end
    end

    context 'when is not created' do
      context 'because of missing attributes' do
        let(:invalid_user_attrs) do
          {
            password: 'password',
            password_confirmation: 'password'
          }
        end

        before(:each) { post :create, { user: invalid_user_attrs }, format: :json }

        it { should respond_with 422 }

        it 'do not creates a user' do
          expect(User.count).to eq 0
        end

        it 'renders an error json' do
          user_response = JSON.parse(response.body, symbolize_names: true)
          expect(user_response).to have_key(:errors)
        end

        it 'renders the json error on why the user could not be created' do
          user_response = JSON.parse(response.body, symbolize_names: true)
          expect(user_response[:errors][:email]).to include "can't be blank"
        end
      end

      context 'because of email already taken' do
        let!(:user) { create(:user, email: 'test@domain.com') }
        let(:valid_user_attrs) do
          {
            email: 'test@domain.com',
            password: 'password',
            password_confirmation: 'password'
          }
        end

        before(:each) { post :create, { user: valid_user_attrs }, format: :json }

        it { should respond_with 422 }

        it 'do not creates a user' do
          expect(User.count).to eq 1
        end

        it 'renders an error json' do
          user_response = JSON.parse(response.body, symbolize_names: true)
          expect(user_response).to have_key(:errors)
        end

        it 'renders the json error on why the user could not be created' do
          user_response = JSON.parse(response.body, symbolize_names: true)
          expect(user_response[:errors][:email]).to include 'has already been taken'
        end
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let!(:user) { create(:user) }

    context 'when is successfully updated' do
      let(:valid_user_attrs) {{ email: 'newemail@domain.com' }}

      before(:each) { patch :update, id: user.id, user: valid_user_attrs, format: :json }

      it { should respond_with 200 }

      it 'renders the json representation for the user record just updated' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq valid_user_attrs[:email]
      end
    end

    context 'when is not updated' do
      let(:invalid_user_attrs) {{ email: 'invalid_mail.com' }}

      before(:each) { patch :update, id: user.id, user: invalid_user_attrs, format: :json }

      it 'renders an errors json' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end

      it 'renders the json errors on whye the user could not be created' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:errors][:email]).to include 'is invalid'
      end

      it { should respond_with 422 }
    end
  end
end
