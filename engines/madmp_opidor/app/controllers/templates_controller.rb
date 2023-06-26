# frozen_string_literal: true

# Templates controller specific to DMP OPIDoR, allows the app to get JSON info about a DMP template 
class TemplatesController < ApplicationController
  after_action :verify_authorized

  def show
    template = ::Template.includes(
      { sections: :questions }
    ).find(params[:id])

    authorize template

    template_data = template.sections.as_json(
      include: {
        questions: {
          only: %w[id text number default_value madmp_schema_id question_format_id]
        }
      }
    )

    render json: template_data
  end
end
