require 'rails_helper'

RSpec.describe "modes/index", type: :view do
  before(:each) do
    assign(:modes, [
      Mode.create!(
        :user_id => 2,
        :name => "Name",
        :known => false,
        :type => "Type",
        :show_input_mode => "Show Input Mode",
        :buffer => "Buffer",
        :goal_badness => 3.5
      ),
      Mode.create!(
        :user_id => 2,
        :name => "Name",
        :known => false,
        :type => "Type",
        :show_input_mode => "Show Input Mode",
        :buffer => "Buffer",
        :goal_badness => 3.5
      )
    ])
  end

  it "renders a list of modes" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Show Input Mode".to_s, :count => 2
    assert_select "tr>td", :text => "Buffer".to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
  end
end
