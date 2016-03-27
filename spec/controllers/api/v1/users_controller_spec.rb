require 'rails_helper'

describe Api::V1::UsersController do
  describe 'GET #show' do
    let!(:user) { create(:user) }

    before(:each) { get :show, id: user.id }

    it { should respond_with 200 }

    it 'returns the information about the user on a hash' do
      expect(json_response[:email]).to eq user.email
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

      before(:each) { post :create, { user: valid_user_attrs } }

      it { should respond_with 201 }

      it 'renders the json representation for the user record just created' do
        expect(json_response[:email]).to eq valid_user_attrs[:email]
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

        before(:each) { post :create, { user: invalid_user_attrs } }

        it { should respond_with 422 }

        it 'do not creates a user' do
          expect(User.count).to eq 0
        end

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the user could not be created' do
          expect(json_response[:errors][:email]).to include "can't be blank"
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

        before(:each) { post :create, { user: valid_user_attrs } }

        it { should respond_with 422 }

        it 'do not creates a user' do
          expect(User.count).to eq 1
        end

        it 'renders an error json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json error on why the user could not be created' do
          expect(json_response[:errors][:email]).to include 'has already been taken'
        end
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let!(:user) { create(:user) }

    context 'when is successfully updated' do
      let(:valid_user_attrs) {{ email: 'newemail@domain.com' }}

      before(:each) do
        api_authorization_header(user.auth_token)
        patch :update, id: user.id, user: valid_user_attrs
      end

      it { should respond_with 200 }

      it 'renders the json representation for the user record just updated' do
        expect(json_response[:email]).to eq valid_user_attrs[:email]
      end
    end

    context 'when is not updated' do
      context 'because user is not authorized' do
        let(:valid_user_attrs) {{ email: 'newemail@domain.com' }}

        before(:each) { patch :update, id: user.id, user: valid_user_attrs }

        it { should respond_with 401 }

        it 'renders the json error of unauthorize user' do
          expect(json_response[:errors]).to eq 'Not authenticated'
        end
      end

      context 'because of invalid attributes' do
        let(:invalid_user_attrs) {{ email: 'invalid_mail.com' }}

        before(:each) do
          api_authorization_header(user.auth_token)
          patch :update, id: user.id, user: invalid_user_attrs
        end

        it 'renders an errors json' do
          expect(json_response).to have_key(:errors)
        end

        it 'renders the json errors on why the user could not be created' do
          expect(json_response[:errors][:email]).to include 'is invalid'
        end

        it { should respond_with 422 }
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }

    before(:each) do
      api_authorization_header(user.auth_token)
      delete :destroy, id: user.id
    end

    it { should respond_with 204 }

    it 'reduces the amount of users' do
      expect(User.count).to eq 0
    end
  end
end
