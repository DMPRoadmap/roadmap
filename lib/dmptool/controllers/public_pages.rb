# frozen_string_literal: true

module Dmptool

  module Controllers

    module PublicPages

      # The publicly accessible list of participating institutions
      def orgs
        skip_authorization
        ids = Org.where.not(Org.funder_condition).pluck(:id)
        @orgs = Org.participating.where(id: ids)
      end

      # The sign in/account creation options page accessed via the 'Get Started' button
      # on the home page
      # rubocop:disable Naming/AccessorMethodName
      def get_started
        skip_authorization
        render "/shared/_get_started"
      end
      # rubocop:enable Naming/AccessorMethodName

      protected

      # Clean up the file name to make it OS friendly (removing newlines, and punctuation)
      def file_name(title)
        name = title.gsub(/[\r\n]/, " ")
                    .gsub(/[^a-zA-Z\d\s]/, "")
                    .gsub(/ /, "_")

        name.length > 31 ? name[0..30] : name
      end

    end

  end

end
