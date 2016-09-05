module UserHelpers
  def sign_in_with(email, password)
    visit '/users/sign_in'
    fill_in('user_email', with: email )
    fill_in('user_password', with: password )
    find('#sign-in-button').click
  end
end

RSpec.configure do |config|
  config.include UserHelpers
end
