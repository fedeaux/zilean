Given(/^I am signed in$/) do
  login_as(create_or_find_user(:user_ray), :scope => :user)
end

When(/^I am on the dashboard$/) do
  visit '/'
  puts page.driver.error_messages
end

Then(/^I should see the "([^"]*)"$/) do |element|
  expect(page).to have_css dom_element_selector(element)
end

Then(/^I should not see the "([^"]*)"$/) do |element|
  expect(page).not_to have_css dom_element_selector(element)
end

When(/^I "([^"]*)" the "([^"]*)"$/) do |action, element|
  dom_element(element).send action
end
