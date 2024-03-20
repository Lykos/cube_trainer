# frozen_string_literal: true

require 'uri'

def login(user)
  raise ArgumentError unless user.name && user.password && user.email

  visit ''
  find_by_id('toolbar-login').click
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_link_or_button 'Submit'
  within('#user-name') do
    expect(page).to have_text(user.name)
  end
end

# Use a material design select.
# Use the text of the option as `name` and the form control as `from`.
# This is ugly, but it was the only option that I was able to get to work.
def mat_select(name, from: nil, id: nil)
  raise ArgumentError if from && id
  raise ArgumentError unless from || id

  find("mat-select[formControlName='#{from}']").click if from
  find("##{id}").click if id
  find('mat-option', text: name).click
end

# Use a material design checkbox.
# This is ugly, but it was the only option that I was able to get to work.
def mat_checkbox(id:)
  find_by_id(id).check visible: :all
end

def extract_first_link_path(email)
  email.body.match(%r{(?:"https?://.*?)(/.*?)(?:")}).captures[0]
end

def replace_capybara_port(url)
  uri = URI.parse(url)
  uri.port = Capybara.current_session.server.port
  uri
end

def replaced_redirect_url(path)
  uri = URI.parse(path)
  query_params = URI.decode_www_form(uri.query || '')
  query_params.map! do |key, value|
    if key == 'redirect_url'
      [key, replace_capybara_port(value)]
    else
      [key, value]
    end
  end
  modified_query_string = URI.encode_www_form(query_params)
  uri.query = modified_query_string
  uri.to_s
end
