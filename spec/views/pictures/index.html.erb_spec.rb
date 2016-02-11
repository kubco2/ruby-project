require 'rails_helper'

RSpec.describe "pictures/index", type: :view do
  before(:each) do
    assign(:pictures, [
      Picture.create!(),
      Picture.create!()
    ])
  end

  it "renders a list of pictures" do
    render
  end
end
