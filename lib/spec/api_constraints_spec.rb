require 'rails_helper'

describe ApiConstraints do
  let(:api_constraints_v1) { described_class.new(version: 1) }
  let(:api_constraints_v2) { described_class.new(version: 2, default: true) }

  describe 'matches?' do
    it "returns true when the version matches the 'Accept' header" do
      request = double(host: 'api.market_place_api.dev',
                       headers: { 'Accept' => 'application/vnd.marketplace.v1' })
      expect(api_constraints_v1.matches?(request)).to eq true
    end

    it "returns the default version when the 'default' option is specified" do
      request = double(host: 'api.marketplace.dev')
      expect(api_constraints_v2.matches?(request)).to eq true
    end
  end
end
