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

  describe '#user_signed_in?' do
    let!(:user) { create(:user) }

    context "when there is a user on 'session'" do
      before(:each) { allow(subject).to receive(:current_user).and_return(user) }

      it { should be_user_signed_in }
    end

    context "when there is no user on 'session'" do
      before(:each) { allow(subject).to receive(:current_user).and_return(nil) }

      it { should_not be_user_signed_in }
    end
  end
end
