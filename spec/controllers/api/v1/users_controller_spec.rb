require 'rails_helper'

describe Api::V1::UsersController do
  before(:each) { request.headers['Accept'] = 'application/vnd.marketplace.v1' }

  describe 'GET #show' do
    let!(:user) { create(:user) }

    before(:each) { get :show, id: user.id, format: :json }

    it { should respond_with 200 }

    it 'returns the information about the user on a hash' do
      user_reponse = JSON.parse(response.body, symbolize_names: true)
      expect(user_reponse[:email]).to eq user.email
    end
  end
end
