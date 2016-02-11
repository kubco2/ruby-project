require 'rails_helper'

RSpec.describe "subscriptions/edit", type: :view do
  before(:each) do
    @subscription = assign(:subscription, Subscription.create!(
      :state => "MyString"
    ))
  end

  it "renders the edit subscription form" do
    render

    assert_select "form[action=?][method=?]", subscription_path(@subscription), "post" do

      assert_select "input#subscription_state[name=?]", "subscription[state]"
    end
  end
end
