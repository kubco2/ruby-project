require 'rails_helper'

RSpec.describe "subscriptions/new", type: :view do
  before(:each) do
    assign(:subscription, Subscription.new(
      :state => "MyString"
    ))
  end

  it "renders new subscription form" do
    render

    assert_select "form[action=?][method=?]", subscriptions_path, "post" do

      assert_select "input#subscription_state[name=?]", "subscription[state]"
    end
  end
end
