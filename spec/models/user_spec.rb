require 'rails_helper'

describe User do
  let!(:user) { create(:user) }

  subject { user }

  it { should be_valid }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('test@domain.com').for(:email) }
end
