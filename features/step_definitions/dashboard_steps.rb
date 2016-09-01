Given(/^I am signed in$/) do
  login_as(create_or_find_user(:user_ray), :scope => :user)
end

When(/^I am on the dashboard$/) do
  visit '/'
end

Then(/^I should see (the|an|a|\d+) (.+)$/) do |type, element|
  expect(page).to have_css dom_element_selector(element, type: type)
end

Then(/^I should not see (the|an|a) (.+)$/) do |type, element|
  expect(page).not_to have_css dom_element_selector(element, type: type)
end

When(/^I (click|hover) on the (.+)$/) do |action, element|
  dom_element(element).send action
end

When(/^I fill the (.+) with (.+)$/) do |form_element, parameter_list|
  form_object = form_element.split('form').first.strip.gsub(/\s+/, '_')
  fill_form_with dom_element(form_element), form_object, parse_parameter_list(parameter_list)
end
