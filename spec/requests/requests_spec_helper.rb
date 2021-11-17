# frozen_string_literal: true

# Can be used in the following ways:
# * `login(username, password)`
# * `login(email, password)`
# * `login(user)`
def post_login(username_or_email_or_user, password = nil)
  if password
    username_or_email = username_or_email_or_user
    post '/api/login',
         params: { username_or_email: username_or_email, password: password },
         headers: headers
  else
    user = username_or_email_or_user
    post '/api/login',
         params: { username_or_email: user.name, password: user.password },
         headers: headers
  end
end
