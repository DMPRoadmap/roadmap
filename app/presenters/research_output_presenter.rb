# frozen_string_literal: true

class ResearchOutputPresenter

  attr_accessor :research_output

  def initialize(research_output:)
    @research_output = research_output
  end

  # Returns the output_type list for a select_tag
  def selectable_output_types
    ResearchOutput.output_types
                  .map { |k, _v| [k.humanize, k] }
  end

  # Returns the mime_type list for a select_tag
  def selectable_mime_types
    @research_output.available_mime_types
                    .reject { |mime| mime.description.downcase.include?("deprecated") }
                    .sort { |a, b| a.value.downcase <=> b.value.downcase }
                    .map { |mime| [mime.value, mime.id] }
  end

  def selectable_access_types
    ResearchOutput.accesses
                  .map { |k, _v| [k.humanize, k] }
  end

  # TODO: These values should either live as an enum on the Model or in the DB
  def selectable_coverage_regions
    %w[africa americas antarctic arctic asia australia europe middle_east
       polynesia].map { |region| [region.humanize, region] }
  end

  # Returns the abbreviation if available or a snippet of the title
  def display_name
    return "" unless @research_output.is_a?(ResearchOutput)
    return @research_output.abbreviation if @research_output.abbreviation.present?

    "#{@research_output.title[0..20]} ..."
  end

  # Returns the abbreviation if available or a snippet of the title
  def display_type
    return "" unless @research_output.is_a?(ResearchOutput)
    # Return the user entered text for the type if they selected 'other'
    return output_type_description if @research_output.other?

    @research_output.output_type.gsub("_", " ").capitalize
  end

end
