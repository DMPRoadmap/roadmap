# frozen_string_literal: true

# Make sure non-trivial amounts of code changes come with corresponding tests
has_app_changes = !git.modified_files.grep(/lib/).empty? || !git.modified_files.grep(/app/).empty?
has_test_changes = !git.modified_files.grep(/spec/).empty?

if git.lines_of_code > 50 && has_app_changes && !has_test_changes
  warn('There are code changes, but no corresponding tests. ' \
       'Please include tests if this PR introduces any modifications in ' \
       'behavior. \n
       Ignore this warning if the PR ONLY contains translation.io synced updates.',
       sticky: false)
end

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
warn('Please add a detailed summary in the description.') if github.pr_body.length < 3

# Warn when there is a big PR
warn('This PR is too big! Consider breaking it down into smaller PRs.') if git.lines_of_code > 1000

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn('PR is classed as Work in Progress') if github.pr_title.include? '[WIP]'

# Let people say that this isn't worth a CHANGELOG entry in the PR if they choose
declared_trivial = (github.pr_title + github.pr_body).include?('#trivial') || !has_app_changes

if !git.modified_files.include?('CHANGELOG.md') && !declared_trivial
  failure(
    "Please include a CHANGELOG entry. \n
    You can find it at [CHANGELOG.md](https://github.com/DMPRoadmap/roadmap/blob/main/CHANGELOG.md).",
    sticky: false
  )
end
