# frozen_string_literal: true

module Dmptool

  module Controller

    module PublicPages

      # The publicly accessible list of participating institutions
      def orgs
        skip_authorization
        ids = Org.where("#{Org.organisation_condition} OR #{Org.institution_condition}")
                 .pluck(:id)
        @orgs = Org.participating.where(id: ids)
      end

      # The sign in/account creation options page accessed via the 'Get Started' button
      # on the home page
      def get_started
        skip_authorization
        render "/shared/_get_started"
      end

      protected

      # Clean up the file name to make it OS friendly (removing newlines, and punctuation)
      def file_name(title)
        file_name = title.gsub(/[^a-zA-Z\d\s]/, "")
                         .gsub(/ /, "_")
                         .gsub('/\n/', "")
                         .gsub('/\r/', "")
                         .gsub(":", "_")
        if file_name.length > 31
          file_name = file_name[0..30]
        end
        file_name
      end

    end

  end

end
