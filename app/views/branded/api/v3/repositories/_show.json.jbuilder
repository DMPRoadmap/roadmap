# frozen_string_literal: true

# locals: repo

json.name repo.name.humanize
json.description repo.description
json.url repo.homepage
json.dmproadmap_host_id do
  json.type 'url'
  json.identifier repo.uri
end