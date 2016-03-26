require 'rails_helper'

describe Api::V1::SessionsController do
  describe 'POST #create' do
    let!(:user) { create(:user) }

    context 'when the credentials are correct' do
      let(:valid_credentials) {{ email: user.email, password: user.password }}

      before(:each) { post :create, session: valid_credentials }

      it { should respond_with 200 }

      it 'returns the user record corresponding to the given credentials' do
        expect(json_response[:auth_token]).to eq user.reload.auth_token
      end
    end

    context 'when the credentials are incorrect' do
      let(:invalid_credentials) {{ email: user.email, password: 'invalid_password' }}

      before(:each) { post :create, session: invalid_credentials }

      it { should respond_with 422 }

      it 'returns a json with an error' do
        expect(json_response[:errors]).to eq 'Invalid email or password'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }

    before(:each) do
      user.generate_authentication_token!
      delete :destroy, id: user.reload.auth_token
    end

    it { should respond_with 204 }
  end
end
