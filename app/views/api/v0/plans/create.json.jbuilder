# frozen_string_literal: true

# builds a json response to a successful project createtion

json.prettify!

json.plan do
  json.title      @plan.title
  json.template   @plan.template.title
  # TODO: add after decision on user creation/identification
  json.created_by @plan.owner.email
  json.id         @plan.id
  json.created_at @plan.created_at
end
