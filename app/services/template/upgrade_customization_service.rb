# frozen_string_literal: true

class Template

  # Service object to upgrade a customization Template with new changes from the original
  # funder Template. Remember: {target_template} is a customization of funder Template.
  #
  # - Duplicate the init template (Duplication called {#customized_template})
  #
  # - Create a new customisation of funder template (Customization called
  #   {#target_template})
  #
  # - Take each phase on the {#target_template} and iterate to find if there's a
  #   corresponding one in {#customized_template}
  #   - Test for each of  corresponding phase in source
  #   - Copy over each of the modifiable sections from source to the target
  #     - Re-number the sections if necessary to keep the display order (number) the same
  #     - Copy each of the questions and annotations exactly
  #   - For each unmodifiable section, copy over any modifiable questions from target
  #
  # - Copy each of the modifiable sections from the {#customized_template} to the
  #   {#target_template}
  #
  class UpgradeCustomizationService

    # Exception raised when the Template is not a customization.
    class NotACustomizationError < StandardError
    end

    # Exception raised when no published funder Template can be found.
    class NoFunderTemplateError < StandardError
    end

    ##
    # The Template we're upgrading
    #
    # Returns {Template}
    attr_reader :init_template

    # Initialize a new instance and run the script
    #
    # template - The Template we're upgrading
    #
    # Returns {Template}
    def self.call(template)
      new(template).call
    end

    private_class_method :new

    # Initialize a new record
    #
    # template - The Template we're upgrading. Sets the value for {#init_template}
    #
    def initialize(template)
      @init_template = template
    end

    # Run the script
    #
    # Returns {Template}
    def call
      Template.transaction do
        if init_template.customization_of.blank?
          raise NotACustomizationError,
                _("upgrade_customization! requires a customised template")
        end
        if funder_template.nil?
          # rubocop:disable Layout/LineLength
          raise NoFunderTemplateError,
                _("upgrade cannot be carried out since there is no published template of its current funder")
          # rubocop:enable Layout/LineLength
        end

        # Merges modifiable sections or questions from source into target_template object
        target_template.phases.map do |funder_phase|
          # Search for the phase in the source template whose versionable_id matches the
          # customization_phase
          customized_phase = find_matching_record_in_collection(
            record: funder_phase,
            collection: customized_template.phases
          )
          # a) If the Org's template ({#customized_template}) has the Phase...
          next unless customized_phase.present?

          # b) If the Org's template ({#customized_template}) doesn't have this Phase.
          #    This is not a problem, since {#customization_template} should have this
          #    Phase copied over from {#template_phase}.
          copy_modifiable_sections_for_phase(customized_phase, funder_phase)
          sort_sections_within_phase(funder_phase)
        end
        copy_custom_annotations_for_questions
      end
      target_template
    end

    private

    # The funder Template for this {#template}
    #
    # Returns Template
    def funder_template
      @funder_template ||= Template.published(init_template.customization_of).first
    end

    # A copy of the Template we're currently upgrading. Preserves modifiable flags from
    # the self template copied
    #
    #
    # Returns {Template}
    def customized_template
      @customized_template ||= init_template.deep_copy(attributes: {
                                                         version: init_template.version + 1,
                                                         published: false
                                                       })
    end

    # Creates a new customisation for the published template whose family_id {#template}
    # is a customization of
    #
    # Returns {Template}
    def target_template
      @target_template ||= funder_template.deep_copy(
        attributes: {
          version: customized_template.version,
          published: customized_template.published,
          family_id: customized_template.family_id,
          customization_of: customized_template.customization_of,
          org: customized_template.org,
          visibility: Template.visibilities[:organisationally_visible],
          is_default: false
        }, modifiable: false, save: true
      )
    end

    # Find an item within collection that has the same versionable_id as record
    #
    # record      - The record we're searching for a match of
    # collection  - The collection of records we're searching in
    #
    # Returns Positionable
    #
    # Returns nil
    def find_matching_record_in_collection(record:, collection:)
      collection.detect { |item| item.versionable_id == record.versionable_id }
    end

    # Attach modifiable sections into the customization phase
    #
    # source_phase - A Phase to copy sections for.
    # target_phase - A Phase to copy Sections to.
    #
    # Returns Array of Sections
    def copy_modifiable_sections_for_phase(source_phase, target_phase)
      source_phase.sections.select(&:modifiable?).each do |section|
        if section.number.in?(target_phase.sections.pluck(:number))
          section.number = target_phase.sections.maximum(:number) + 1
        end
        target_phase.sections.append(section) or
          raise("Unable to add Section##{section.id} to Phase##{target_phase.id}")
      end
    end

    def copy_custom_annotations_for_questions
      init_template.annotations.where(org: template_org).each do |custom_annotation|
        target_question = target_template.questions.find_by(
          versionable_id: custom_annotation.question.versionable_id
        )
        target_question.annotations << custom_annotation if target_question.present?
      end
    end

    def sort_sections_within_phase(phase)
      phase.sections = SectionSorter.new(*phase.sections).sort!
    end

    def template_org
      init_template.org
    end

  end

end
