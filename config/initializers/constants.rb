LANGUAGES = (ActiveRecord::Base.connection.table_exists? 'languages') ? Language.sorted_by_abbreviation : []
MANY_LANGUAGES = LANGUAGES.length > 1
TABLE_FILTER_MIN_ROWS = 10

# Default Feedback Request Email sent to the requesting user
# This email can be overriden by local Org Admins on the Org Details page
# TODO: Move this to a location that gets loaded AFTER FastGettext so that we can  use fastgettext to manage localisations
EMAIL_FEEDBACK_REQUESTED_CONFIRMATION_SUBJECT = 'Your DMP has been submitted for feedback in %{application_name}'
EMAIL_FEEDBACK_REQUESTED_CONFIRMATION_MESSAGE = '<p>Hello [user_name],</p>'\
  '<p>Your DMP "[plan_name]" has been submitted for feedback from an administrator at your institution.  If you have questions pertaining to this action, please contact your local administrator at [organisation_email].</p>'\
  '<p>All the best,<br />The %{application_name} team.</p>'
