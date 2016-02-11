require 'rails_helper'

RSpec.describe "subscriptions/show", type: :view do
  before(:each) do
    @subscription = assign(:subscription, Subscription.create!(
      :state => "State"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/State/)
  end
end
