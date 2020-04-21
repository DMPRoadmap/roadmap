# frozen_string_literal: true

json.partial! "api/v1/standard_response", total_items: @total_items

json.items @items do |template|
  presenter = Api::V1::TemplatePresenter.new(template: template)

  json.dmp_template do
    json.title presenter.title
    json.description template.description
    json.version template.version
    json.created template.created_at.utc.to_s
    json.modified template.updated_at.utc.to_s

    json.affiliation do
      json.partial! "api/v1/orgs/show", org: template.org
    end

    json.template_id do
      identifier = Api::V1::ConversionService.to_identifier(context: @application,
                                                            value: template.id)
      json.partial! "api/v1/identifiers/show", identifier: identifier
    end
  end
end
