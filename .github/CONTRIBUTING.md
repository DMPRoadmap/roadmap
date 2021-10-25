## Introduction
The goal of the DMPRoadmap project is to provide the community with a reliable and stable platform for managing data management plans. This means that all development efforts should adhere to some basic tenets to ensure that the system remains stable and provides functionality for the community as a whole.

These guidelines are an attempt to ensure that we are able to provide the community with a reliable system, stable APIs, a clear roadmap, and a predictable release schedule. 

A contribution consists of any work that is voluntarily submitted to the project. This includes bug fixes, enhancements and documentation that is intended as an improvement to the DMP Roadmap system.

### Let us know that you'll be working on the issue!

If you would like to contribute a feature or bug fix, let us know by commenting on the ticket. We can track the ticket and ensure that no one else is working on it at the same time.

### Forking the repository

If you would like to contribute to the project and have not yet forked the codebase, click on the 'Fork' button in the upper right hand corner of this page. This will create a copy of the DMPRoadmap repository for you to work with.

Once the fork has been created, clone the repository onto your machine. See Github's (documentation on cloning)[https://help.github.com/articles/cloning-a-repository/].

On your local machine, add a remote that points to the original DMPRoadmap codebase. This will allow you to pull down the latest changes and sync up your forked repository

Run the following from your local clone of the repository to setup a remote that will allow you to pull down the latest changes from DMPRoadmap. Then pull down the development branch:
```bash
git remote add upstream https://github.com/DMPRoadmap/roadmap.git
git fetch development
```

### Pulling down the latest changes from DMPRoadmap into your fork

If you've already forked the project, you should make sure you pull down the latest changes before working on yoour feature, bug fix or translations.



### Create a new feature/bug fix/translations branch 

You should always base your new branch off of the development branch. We keep this branch up to date with the latest release. Checkout the development branch, sync it with DMPRoadmap and then push the latest up to your own fork:

```bash
git checkout development
git pull upstream development
git push origin development
git checkout -b [my-branch]
```

The name of the branch is up to you. Once your branch has been created you can start making changes. 

Please refer to the pull request checklists below to make sure you've included everything we require in your PR!

### Rebase your commits

This is only necessary if you have made more than one git commit on your feature branch.

When you are finished making changes, we ask that all contributors squash their commits into a single git commit. This helps us keep the git history clean and makes it easier to revert any changes if necessary.

_Note that if this is your first time rebasing a branch we recommend making a backup of the branch first since a rebase creates the potential for you to lose your changes if its done incorrectly: `git checkout -b [feature branch]-bak && git checkout [feature branch]`_

To rebase your feature branch you should follow this example:
  
First locate the last commit that occurred before your changes were made in the feature branch by using `git log`. Here is an of a recent bug fix branch:
```bash
commit c74a4ecdb37c0d4396e97db019f35d8a5000d069 (HEAD -> issue1603)
Author: John Doe <john.doe@example.org>
Date:   Fri Jun 15 13:33:27 2018 -0700

    added isActiveTab for profile and reference pages

commit 2b003da459cc5d605dda534898ea4bf89b4f2172
Author: John Doe <john.doe@example.org>
Date:   Fri Jun 15 13:26:40 2018 -0700

    fixed issue with active tabs

commit bd9b31d8ca1dcee5e82639dfd9b41a4e2618e2bc (upstream/development, development)
Merge: f4d058df 7ca739e3
Author: Another Developer <developer2@example.org>
Date:   Fri Jun 14 09:20:41 2018 +0100

    Merge pull request #1610 from CDLUC3/issue1333
```

In the git log above, the developer has made two commits ('fixed issue with active tabs' and 'added isActiveTab for profile and reference pages'). Before they contribute this bug fix back to the core codebase they need to squash those 2 commits into one. To do that, they should copy the last commit id for the commit that happened before they started making changes. In this case they would copy 'bd9b31d8ca1dcee5e82639dfd9b41a4e2618e2bc' from the 'Merge pull request #1610 from CDLUC3/issue1333' commit.

Once you've identified the correct commit id run the rebase command with the '-i' flag: ` git rebase -i bd9b31d8ca1dcee5e82639dfd9b41a4e2618e2bc`

This will open an editor window that will ask you to pick/squash your commits. You should always 'pick' the first one in the list and 'squash' all others. So in our example:
```bash
pick 2b003da4 fixed issue with active tabs
pick c74a4ecd added isActiveTab for profile and reference pages       <--- Change this one to 'squash'

# Rebase bd9b31d8..c74a4ecd onto bd9b31d8 (2 commands)
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

After you have saved your options, a second merge window will open. This is a normal merge/rebase message. You can adjust the comments in this second window if you like and save.

Now your code changes have been rebased into a single commit. To verify that things worked properly do another `git log`. You should see all of your commit messages under a single commit now. For our example, we will now see:

```bash
commit c691ed712a5d09cf1a9adb8b4e0be92f2bf94641 (HEAD -> issue1603)
Author: John Doe <john.doe@example.org>
Date:   Fri Jun 15 13:26:40 2018 -0700

    fixed issue with active tab                                 <--- Our first commit (the one we picked)
    
    added isActiveTab for profile and reference pages

commit bd9b31d8ca1dcee5e82639dfd9b41a4e2618e2bc (upstream/development, development)
Merge: f4d058df 7ca739e3
Author: Another Developer <developer2@example.org>
Date:   Fri Jun 14 09:20:41 2018 +0100

    Merge pull request #1610 from CDLUC3/issue1333
```

### Push your branch up to your fork and send us a Pull Request (PR)

Once your changes are complete, push your branch up to your fork, `git push origin [my-branch]`

Then login to Github and go to your fork. Select your branch from the list and click 'New Pull Request'. On the page that opens, select the 'development' branch on the DMPRoadmap section. 

Then review your code and provide us with detailed comments about what the changes are doing (e.g. adding a new feature, fixing a recorded bug, etc.). If you are working off of one of our Github issues, then please note that in the PR message with a `Fixes #1234`.

The project team will evaluate each PR as time permits and communicate with the contributor via comments on the PR. We will not accept a contribution until it adheres to the guidelines outlined in this document. If your contribution fits well with the project roadmap, the team will merge it into the project and schedule it for the next upcoming release. 

### Code review  
 
Once we receive your PR, at lest one member of the core development team will review the code and provide you with feedback through GitHub PR review feature. If any changes are requested, you should follow the process above to commit your additional changes, rebase again, and push your changes back up to Github. You do not need to close the PR and open another if you are working with the same branch. Note that if you rebase again you will need to force the push: `git push -f origin [my-branch]`

### Acceptence of your PR

Once your code has been approved a member of the core development team will merge it into the development branchand include it in an upcoming release. 

At this point its a good idea to delete the branch from your fork in Github and also delete it from your local machine via:
```bash
git checkout development
git branch -D [my-branch]
```

### Pull Request Checklists

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
