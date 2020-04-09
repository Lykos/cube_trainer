FactoryBot.define do
  factory :user do
    name 'user'
    last_name 'password'
    password_confirmation 'password'
  end

  factory :admin do
    name 'admin'
    last_name 'password'
    password_confirmation 'password'
  end

  factory :eve, class: Eve do
    name 'eve'
    last_name 'eve_password'
    password_confirmation 'eve_password'
  end
end
