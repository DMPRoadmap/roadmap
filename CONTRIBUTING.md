## Introduction
The goal of the DMPRoadmap project is to provide the community with a reliable and stable platform for managing data management plans. This means that all development efforts should adhere to some basic tenets to ensure that the system remains stable and provides functionality for the community as a whole.

These guidelines are an attempt to ensure that we are able to provide the community with a reliable system, stable APIs, a clear roadmap, and a predictable release schedule. 

* If you would like to contribute to the project, please follow these steps to submit a contribution:
  * Comment on the Github issue (or create one if one does not exist) and let us know that you're working on it.
  * Fork the project (if you have not already) or rebase your fork so that it is up to date with the current repository's **`contributions`** branch
  * Create a new branch in your fork. This will ensure that you are able to work at your own pace and continue to pull in any updates made to this project.
  * Make your changes in the new branch. When you have finished your work (e.g. 3 commits), squash all the commits on the branch that you are working on:
    ```bash
    git rebase -i HEAD~n  # Where n is the number of commits you want to squash
    ```
    This command's output will look similar to this:
    ```
    pick 819b37a First commit in the feature branch.
    pick 8634c87 More changes in the feature branch.
    pick 59df9aa Third commit in feature branch.

    # Rebase 6c51182..59df9aa onto 6c51182
    ```
    Leave the first commit as `pick` and change `pick` to `squash` for all following commits (to squash them into the single first commit), like so:
    ```
    pick 819b37a First commit in the feature branch.
    squash 8634c87 More changes in the feature branch.
    squash 59df9aa Third commit in feature branch.

    # Rebase 6c51182..59df9aa onto 6c51182
    ```
    Then, change `pick` to `squash` for the 2nd and 3rd commits (to squash them into the single first commit).
  * To make sure that your version of the **`contributions`** branch is still up to date with this project, switch to it and synchronise:
    ```bash
    git checkout contributions
    git pull origin contributions
    ```
  * Switch back to your feature branch and rebase:
    ```bash
    git checkout <feature branch>
    git rebase contributions
    ```
  * Fix merge conflicts (if any encountered) and then push to your fork:
    ```bash
    git push origin <feature branch>
    ```
  * Then create a new Pull Request (PR) to this project's **`contributions`** branch on GitHub.
  * The project team will then review your PR and communicate with you to convey any additional changes that would ensure that your work adheres to our guidelines.
  * Delete your feature branch if it is not required anymore.

Table of contents:
* [Github Workflow](#github-workflow)
* [Pull Requests](#pull-requests)
* [Testing Guidelines](#testing-guidelines)
* [Coding Style/Guidelines](#coding-style)

## GitHub Workflow
A contribution consists of any work that is voluntarily submitted to the project. This includes bug fixes, enhancements and documentation that is intended as an improvement to the DMP Roadmap system.

Any individual with a GitHub account may propose a Contribution by submitting a Pull Request (PR) to this project's **`contributions`** branch. The project team will evaluate each PR as time permits and communicate with the contributor via comments on the PR. We will not accept a contribution until it adheres to the guidelines outlined in this document. If your contribution fits well with the project roadmap, the team will merge it into the project and schedule it for the next upcoming release. 

![GitHub Workflow ](https://github.com/DMPRoadmap/roadmap/blob/master/public/github-contributor-infographic-final.png)

## Pull Requests
Please use these checklists to help you prepare your Pull Request for submission. 

ALL Pull Requests MUST be made to the **`contributions`** branch!

#### Checklist for changes to a database table and/or its corresponding model
* Did you include the appropriate database migration? ```> rails g migration AddTwitterIdToUsers```
* Did you update/add the Unit tests?
* Did your change require you to transform data? For example moving data from one field to another like moving users.organisation_id to a join table called users_organisations. If so, did you include a rake task to help others migrate their data over to the new model (along with instructions)?
* Does the schema.rb include the changes?
* Did you remember to update the seeds.rb file to reflect the change?

#### Checklist for changes to a controller
* Did you update/add the Functional tests?
* Did you update/add the Routing tests (if applicable)?
* Did you update the corresponding view(s)?
* Did you include any updates/additions to localisation text config/locales/pot file?

#### Checklist for changes to a view
* Did you include any updates/additions to localisation text config/locales/pot file?
* Did you update the corresponding controller?
* Did you manually test the change in multiple browsers?
* Did your change require modifications to the CSS, JS or image files? If so did you include them in your branded file locations or in the core system files? For example: lib/assets/javascripts is the default javascript directory. app/assets/javascripts are specific to your local installation. (See [Branding](https://github.com/DMPRoadmap/roadmap/wiki/Branding) for more information)

## Testing Guidelines
First and foremost, all of the existing tests must pass before we accept your contribution. If your work has made a change to an object that results in failed tests then you should update those tests so that they are accurate. 

To run the tests:
```shell
# Make sure that your test DB has all of the current database migrations:
> rake db:migrate RAILS_ENV=test

# To run all of the tests:
> rake test
# To run all of a specific type of tests:
> rake test test/unit/
# To run a specific test:
> rake test test/unit/users_test.rb
```

If you are adding a new feature to the system you must build out the appropriate tests before we will accept your contribution. For example, if I add a new field to the User table that stores the user's Twitter id, I should update the test/unit/users_test.rb Unit test. If my contribution included changes to the User Profile page that allowed the user to enter this new Twitter id then I should update the test/functional/registrations_controller_test.rb Functional controller test.

DMP Roadmap uses the Travis CI framework to verify that are tests are passing. When you create your PR you will see a note stating that the tests are pending. Check back after a few minutes to give the Travis system time to run its tests. 

**Please Note:** We will not review your PR until the tests are passing and GitHub notes that there are no merge conflicts

The original DMP Roadmap codebase did not include a full suite of tests. The project team has been busy adding them in when we can but we still have a long way to go. The requirements mentioned above are in place for pieces of the system that already have tests. For example, if your work involves an enhancement to an existing controller that has no functional test in the current codebase, we do not expect you to write tests for the entire controller (although we would welcome the help!). In cases like this, we only ask that you write tests for the endpoints that you have updated.

We do not currently have testing for the UI components. We plan to add tests for these in the near future using a headless browser like PhantomJS. We welcome any contributors who are willing to begin work in this area!

#### Unit tests:
* The model can be Created, Read/Loaded, Updated and Deleted (CRUD)
* Required fields are required and that the model cannot be saved without those fields 
* Any other validations are working as expected (e.g. email address is in the email format)
* Associations are functioning properly. Use the helper methods in test/test_helper.rb
* All other functions that are defined within the model are tested 
* You should update or create the corresponding fixtures for the model you are testing

#### Functional Controller tests:
* The correct HTTP response was received (200 success, 302 redirect, 401 unauthorized, etc.)
* The user was redirected to the correct page (if applicable)
* All of the instance variables set within the controller were properly defined
* All flash messaging is correct

#### Integration tests:
* Complex workflows that involve multiple pieces of the system should have an integration test. This can include interaction with gem dependencies or external services. For example email, login/logout, etc. 

#### Helper/Service tests:
* Each method within the helper or service should be tested for both success and failure conditions

#### Routing tests:
New controller/API endpoints should have tests within the test/routing_test.rb 

#### General Notes and Advice:
* You should use the Rails URL and Path helpers instead of hard-coding them in your tests. (e.g. edit_plans_path(@plan) instead of '/plans/123/edit'
* You should use the I18n.t method to validate flash messaging rather than hard-coding messages in your tests
* You should include assertions that test both success and failure conditions

## Coding style
We realize that every developer has their own style and we encourage a bit of individuality. However, we do impose some of the following rules to contributions to this project.

* We quite like the principle of [DRY (Don't Repeat Yourself)](https://en.wikipedia.org/wiki/Don't_repeat_yourself) so please always look through the existing code to make sure you are not reinventing something that has already been done. Also clever bits of code or reuse of existing ones to avoid copying and pasting is always appreciated. 
* Include database migrations when you are altering the database model. Use the following command to create a new migration and be specific about what it does in the name of the file

    ```shell
    > rails g migration AddTwitterIdToUsers
    ```
* You do not need to comment every line of your code but we do expect to see inline comments explaining the intent of your if blocks and loops.
* We do not want to see Tab characters. Tabs should be converted to a double space. If you are working on a file that has Tabs already, please convert them for us before making your Pull Request
* If a line is going to go beyond 100 characters please break it out onto multiple lines. For example:

    ```ruby
    # This is preferable 
    users = [{email: @user.email, password: 'bAd_pas$word1', remember_me: true},
             {email: 'unknown@institution.org', password: 'password123', remember_me: true}]

    # to this long line that requires scrolling
    users = [{email: @user.email, password: 'bAd_pas$word1', remember_me: true}, {email: 'unknown@institution.org', password: 'password123', remember_me: true}]
    ```
* Finally, please make sure your code is properly indented as this enhances readability.
