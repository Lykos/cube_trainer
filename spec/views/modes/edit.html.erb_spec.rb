require 'rails_helper'

RSpec.describe "modes/edit", type: :view do
  before(:each) do
    @mode = assign(:mode, Mode.create!(
      :user_id => 1,
      :name => "MyString",
      :known => false,
      :type => "",
      :show_input_mode => "MyString",
      :buffer => "MyString",
      :goal_badness => 1.5
    ))
  end

  it "renders the edit mode form" do
    render

    assert_select "form[action=?][method=?]", mode_path(@mode), "post" do

      assert_select "input[name=?]", "mode[user_id]"

      assert_select "input[name=?]", "mode[name]"

      assert_select "input[name=?]", "mode[known]"

      assert_select "input[name=?]", "mode[type]"

      assert_select "input[name=?]", "mode[show_input_mode]"

      assert_select "input[name=?]", "mode[buffer]"

      assert_select "input[name=?]", "mode[goal_badness]"
    end
  end
end
