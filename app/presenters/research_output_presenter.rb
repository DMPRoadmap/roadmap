# frozen_string_literal: true

class ResearchOutputPresenter

  class << self

    # Returns the abbreviation if available or a snippet of the title
    def display_name(research_output:)
      return "" unless research_output.is_a?(ResearchOutput)
      return research_output.abbreviation if research_output.abbreviation.present?

      "#{research_output.title[0..20]} ..."
    end

    # Returns the abbreviation if available or a snippet of the title
    def display_type(research_output:)
      return "" unless research_output.is_a?(ResearchOutput)
      # Return the user entered text for the type if they selected 'other'
      return output_type_description if research_output.other?

      research_output.output_type.gsub("_", " ").capitalize
    end

  end

end
