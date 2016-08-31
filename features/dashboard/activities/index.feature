Feature: Create Activities

Background:
  Given I am signed in
  When I am on the dashboard
  Then I should see the activities component
   And I should see the add button for the activities component
  When I click on the add button for the activities component
  Then I should see the activity form for the activities component
   And I should see the create activity button

Scenario: Creating an Activity with no previous activities
  When I fill the activity form for the activities component with name: Work
   And I click on the create activity button
  Then I should see an activity list item

Scenario: Creating an Activity with no parent but with previous activities registered
  Given Some activities exist
  When I fill the activity form for the activities component with name: Work
   And I click on the create activity button
  Then I should see an activity list item
