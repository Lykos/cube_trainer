# frozen_string_literal: true

require 'fixtures'

def login(user)
  fill_in 'Username or Email', with: user.name
  fill_in 'Password', with: user.password
  click_button 'Submit'
end

# Use a material design select.
# Use the text of the option as `name` and the form control as `from`.
# This is ugly, but it was the only option that I was able to get to work.
def mat_select(name, from:)
  find("mat-select[formControlName='#{from}']").click
  find('mat-option', text: name).click
end
