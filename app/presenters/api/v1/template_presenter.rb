# frozen_string_literal: true

module Api
  module V1
    # Helper class for the API V1 template info
    class TemplatePresenter
      def initialize(template:)
        @template = template
      end

      # If the plan has a grant number then it has been awarded/granted
      # otherwise it is 'planned'
      def title
        return @template.title unless @template.customization_of.present?

        "#{@template.title} - with additional questions for #{@template.org.name}"
      end
    end
  end
end
