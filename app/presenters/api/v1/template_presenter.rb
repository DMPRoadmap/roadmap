# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

    class TemplatePresenter

=======
  module V1
    # Helper class for the API V1 template info
    class TemplatePresenter
>>>>>>> upstream/master
      def initialize(template:)
        @template = template
      end

      # If the plan has a grant number then it has been awarded/granted
      # otherwise it is 'planned'
      def title
        return @template.title unless @template.customization_of.present?

        "#{@template.title} - with additional questions for #{@template.org.name}"
      end
<<<<<<< HEAD

    end

  end

=======
    end
  end
>>>>>>> upstream/master
end
