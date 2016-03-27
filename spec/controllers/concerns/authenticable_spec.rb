require 'rails_helper'

class Authentication
  include Authenticable

  def request
  end
end

describe Authenticable do
  subject { Authentication.new }

  describe '#current_user' do
    let!(:user) { create(:user) }

    before(:each) do
      allow(subject).to receive(:request).and_return(request)
    end

    context 'when it is a valid token' do
      it 'returns the user from the authorization header' do
        request.headers['Authorization'] = user.auth_token
        expect(subject.current_user.auth_token).to eq user.auth_token
      end
    end

    context 'when it is not a valid token' do
      it 'returns nil' do
        request.headers['Authorization'] = 'invalid_token'
        expect(subject.current_user.present?).to be false
      end
    end
  end
end
