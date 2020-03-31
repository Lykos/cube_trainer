require 'rails_helper'

RSpec.describe "modes/show", type: :view do
  before(:each) do
    @mode = assign(:mode, Mode.create!(
      :user_id => 2,
      :name => "Name",
      :known => false,
      :type => "Type",
      :show_input_mode => "Show Input Mode",
      :buffer => "Buffer",
      :goal_badness => 3.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Show Input Mode/)
    expect(rendered).to match(/Buffer/)
    expect(rendered).to match(/3.5/)
  end
end
