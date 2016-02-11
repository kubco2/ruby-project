require 'rails_helper'

RSpec.describe "subscriptions/index", type: :view do
  before(:each) do
    assign(:subscriptions, [
      Subscription.create!(
        :state => "State"
      ),
      Subscription.create!(
        :state => "State"
      )
    ])
  end

  it "renders a list of subscriptions" do
    render
    assert_select "tr>td", :text => "State".to_s, :count => 2
  end
end
