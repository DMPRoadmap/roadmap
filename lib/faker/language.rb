# frozen_string_literal: true

module Faker

  class Language < Base

    class << self

      def name
        sample(translate("faker.language.names"))
      end

      def names(num = 3)
        resolved_num = resolve(num)
        suffle(translate("faker.language.names"))[0..resolved_num]
      end

      def abbreviation
        sample(translate("faker.language.abbreviations"))
      end

      def abbreviations(num = 3)
        resolved_num = resolve(num)
        suffle(translate("faker.language.abbreviations"))[0..resolved_num]
      end

      private

      def resolve(value)
        case value
        when Array then sample(value)
        when Range then rand value
        else value
        end
      end

    end

  end

end
