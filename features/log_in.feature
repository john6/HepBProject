Feature: log in as volunteer
	as a registered volunteer
	so that I can access my profile
	I want to log in with my email and password

Background: members have been added to database

 Given the following members exist:
  | first_name   | last_name  | grad_date    | phone       | email                 | password    | is_admin | 
  | Judy         | Blume      | May 15, 2015 | 5555555555  | judyBlume@gmail.com   | 12345678    | no       | 
 
 And I am on the portal login page

Scenario: Successful login 
	When I fill in "Email" with "judyBlume@gmail.com"
	And I fill in "Password" with "12345678"
	And I press "Log in"
	Then I should be on the portal dashboard for "Judy"

Scenario: Unsuccessful login (No username) 
	When I fill in "Email" with "blah"
	And I fill in "Password" with "blerg"
	And I press "Log in"
	Then I should be on the portal login page
	And I should see "Invalid email or password. Login Email Password Sign up Forgot your password?"

Scenario: Unsuccessful login (Incorrect password) 
	When I fill in "Email" with "judyBlume@gmail.com"
	And I fill in "Password" with "blerggg"
	And I press "Log in"
	Then I should be on the portal login page
	And I should see "Invalid email or password. Login Email Password Sign up Forgot your password?" 

Scenario: Unsuccessful login (blank feilds)
	When I fill in "Email" with "judyBlume@gmail.com"
	And I press "Log in"
	Then I should be on the portal login page
	And I should see "Invalid email or password. Login Email Password Sign up Forgot your password?"
