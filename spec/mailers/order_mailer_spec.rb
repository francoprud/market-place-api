require "rails_helper"

describe OrderMailer do
  include Rails.application.routes.url_helpers

  let!(:user)    { create(:user) }
  let!(:product) { create(:product) }
  let!(:order)   { create(:order, user: user, product_ids: [product.id]) }

  before(:each) { @email = described_class.send_confirmation(order) }

  it 'delivers to the user owner of the order' do
    expect(@email).to deliver_to(user.email)
  end

  it 'delivers from no-reply@marketplace.com' do
    expect(@email).to deliver_from('no-reply@marketplace.com')
  end

  it 'contains the user message in the mail body' do
    expect(@email).to have_body_text(/Order: ##{order.id}/)
  end

  it 'contains the correct subject' do
    expect(@email).to have_subject(/Order Confirmation/)
  end

  it 'contains the product count' do
    expect(@email).to have_body_text(/You ordered #{order.products.count} products:/)
  end
end
