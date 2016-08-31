Feature: Dashborad Component Visibility

Scenario: Viewing dashboard
Given I am signed in
When I am on the dashboard
Then I should see the "dashboard controls"

Scenario: Hiding a component
Given I am signed in
When I am on the dashboard
Then I should see the "activities component"
When I "click" on the "close button for the activities component"
Then I should not see the "activities component"
