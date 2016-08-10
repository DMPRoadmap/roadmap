# builds a json response to a successful project createtion

json.prettify!

json.project do
  json.title      @project.title
  # TODO add after decision on user creation/identification
  #json.created_by @project.owner.email
  json.id         @project.id
  json.created_at @project.created_at
end

# json.location do
#   json.link       (url_for action: 'show', controller: 'project')
# end
