# frozen_string_literal: true

# Templates controller specific to DMP OPIDoR, allows the app to get JSON info about a DMP template 
class TemplatesController < ApplicationController
  after_action :verify_authorized

  def show
    template = ::Template.includes(
      { sections: :questions }
    ).find(params[:id])

    authorize template, policy_class: PublicTemplateInfoPolicy

    template_data = template.sections.as_json(
      include: {
        questions: {
          only: %w[id text number default_value question_format_id],
          include: { madmp_schema: { only: %w[id classname] } }
        }
      }
    )

    render json: {
      locale: template.locale,
      title: template.title,
      version: template.version,
      org: template.org.name,
      structured: template.structured?,
      publishedDate: template.updated_at.to_date,
      sections: template_data
    }
  end
end
