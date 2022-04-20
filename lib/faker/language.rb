# frozen_string_literal: true

module Faker
<<<<<<< HEAD

  class Language < Base

    class << self

      def name
        sample(translate("faker.language.names"))
=======
  # Monkey patch for Faker to add support for our locales
  class Language < Base
    class << self
      def name
        sample(translate('faker.language.names'))
>>>>>>> upstream/master
      end

      def names(num = 3)
        resolved_num = resolve(num)
<<<<<<< HEAD
        suffle(translate("faker.language.names"))[0..resolved_num]
      end

      def abbreviation
        sample(translate("faker.language.abbreviations"))
=======
        suffle(translate('faker.language.names'))[0..resolved_num]
      end

      def abbreviation
        sample(translate('faker.language.abbreviations'))
>>>>>>> upstream/master
      end

      def abbreviations(num = 3)
        resolved_num = resolve(num)
<<<<<<< HEAD
        suffle(translate("faker.language.abbreviations"))[0..resolved_num]
=======
        suffle(translate('faker.language.abbreviations'))[0..resolved_num]
>>>>>>> upstream/master
      end

      private

      def resolve(value)
        case value
        when Array then sample(value)
        when Range then rand value
        else value
        end
      end
<<<<<<< HEAD

    end

  end

=======
    end
  end
>>>>>>> upstream/master
end
