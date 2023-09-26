# frozen_string_literal: true

json.partial! 'api/v3/standard_response'

json.items @items do |item|
  if item.is_a?(Org) || item.is_a?(RegistryOrg)
    json.partial! 'api/v3/orgs/show', locals: { org: item, use_funder_context: @use_funder_context }
  end

  if item.is_a?(Repository)
    json.partial! 'api/v3/repositories/show', locals: { repo: item }
  end

  if item.is_a?(Hash)
    json.label item[:label]
    json.value item[:value]
    json.allow_size_specification item[:allow_size_specification]
  end
end
