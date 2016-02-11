require 'rails_helper'

RSpec.describe "pictures/show", type: :view do
  before(:each) do
    @picture = assign(:picture, Picture.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
