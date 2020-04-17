shared_context :headers do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
end

def login(username_or_email, password)
  post "/login", params: { username_or_email: username_or_email, password: password }, headers: headers
end
