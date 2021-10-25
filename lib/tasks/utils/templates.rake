# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Metrics/BlockLength, Metrics/AbcSize
namespace :templates do
  desc "Repair Templates whose descendents have NIL versionable_id values"
  task fix_templates_with_nil_versionable_ids: :environment do
    p "Attempting to repair versionable_ids"

    safe_require "text"

    # Remove attr_readonly restrictions form these models
    Phase.attr_readonly.delete("versionable_id")
    Section.attr_readonly.delete("versionable_id")
    Question.attr_readonly.delete("versionable_id")
    QuestionOption.attr_readonly.delete("versionable_id")
    Annotation.attr_readonly.delete("versionable_id")

    # Get each of the latest versions of the non-customized templates
    Template.latest_version.where(customization_of: nil)
            .includes(phases: { sections: { questions: %i[annotations question_options] } })
            .each do |funder_template|
      # When testing, use this line to restrict the process to specified templates
      # next unless [586, 1144].include?(funder_template.id)

      # Fetch all of the prior versions of the template
      prior_versions = Template.where(customization_of: nil, family_id: funder_template.family_id)
                               .where.not(id: funder_template.id)
                               .includes(phases: { sections: { questions: %i[annotations question_options] } })

      funder_template.phases.select { |phase| phase.versionable_id.nil? }.each do |phase|
        p "Processing Template: #{funder_template.id} - #{funder_template.title}"

        # Run all of this within a transation so that it rolls back if there is an issue!
        phase.transaction do
          phase_version = SecureRandom.uuid
          p "  Updating versionable_id for Phase: #{phase.id} to #{phase_version}"
          phase.update_columns(versionable_id: phase_version)

          update_related_versionable_ids(
            original: phase,
            related_records: prior_versions.map(&:phases).flatten.select { |p| p.versionable_id.nil? },
            versionable_id: phase_version
          )

          phase.sections.select { |sec| sec.versionable_id.nil? }.each do |section|
            section_version = SecureRandom.uuid
            p "      Updating versionable_id for Section: #{section.id} to #{section_version}"
            section.update_columns(versionable_id: section_version)

            update_related_versionable_ids(
              original: section,
              related_records: prior_versions.map(&:sections).flatten.select { |s| s.versionable_id.nil? },
              versionable_id: section_version
            )

            section.questions.select { |ques| ques.versionable_id.nil? }.each do |question|
              question_version = SecureRandom.uuid
              p "        Updating versionable_id for Question: #{question.id} to #{question_version}"
              question.update_columns(versionable_id: question_version)

              update_related_versionable_ids(
                original: question,
                related_records: prior_versions.map(&:questions).flatten.select { |q| q.versionable_id.nil? },
                versionable_id: question_version
              )

              question.question_options.select { |o| o.versionable_id.nil? && o.text.present? }.each do |option|
                option_version = SecureRandom.uuid
                p "        Updating versionable_id for QuestionOption: #{option.id} to #{option_version}"
                option.update_columns(versionable_id: option_version)

                update_related_versionable_ids(
                  original: option,
                  related_records: prior_versions.map(&:question_options).flatten.select { |q| q.versionable_id.nil? },
                  versionable_id: option_version
                )
              end

              question.annotations.select { |a| a.versionable_id.nil? && a.text.present? }.each do |annotation|
                annotation_version = SecureRandom.uuid
                p "        Updating versionable_id for Annotation: #{annotation.id} to #{annotation_version}"
                annotation.update_columns(versionable_id: annotation_version)

                update_related_versionable_ids(
                  original: annotation,
                  related_records: prior_versions.map(&:annotations).flatten.select { |q| q.versionable_id.nil? },
                  versionable_id: annotation_version
                )
              end
            end
          end
        end
      end
    end

    # Add versionable_id to any customized Templates
    Template.latest_version.where.not(customization_of: nil)
            .includes(phases: { sections: { questions: %i[annotations question_options] } })
            .each do |customized_template|
      # When testing, use this line to restrict the process to specified templates
      # next unless [586, 1144].include?(customized_template.id)

      customized_template.transaction do
        parent_template = Template.latest_version
                                  .where(family_id: customized_template.customization_of)
                                  .includes(phases: { sections: { questions: %i[annotations question_options] } })
                                  .first

        # Fetch all of the prior versions of the template
        prior_versions = Template.where(family_id: customized_template.family_id)
                                 .where.not(id: customized_template.id)
                                 .includes(phases: { sections: { questions: %i[annotations question_options] } })

        customized_template.phases.each do |phase|
          p "Processing Customization: #{customized_template.id} - #{customized_template.title}"
          unless phase.versionable_id.present?
            version = find_related_versionable_id(original_template: parent_template, record: phase)
            version = SecureRandom.uuid unless version.present?
            p "  Updating versionable_id for Phase: #{phase.id} to #{version}"
            phase.update_columns(versionable_id: version)
          end

          update_related_versionable_ids(
            original: phase,
            related_records: prior_versions.map(&:phases).flatten.select { |p| p.versionable_id.nil? },
            versionable_id: phase.versionable_id
          )

          phase.sections.select { |s| s.versionable_id.nil? }.each do |section|
            p "Updating versionable_id for custom template section #{section.id} and its questions/options/annotations"
            unless section.versionable_id.present?
              version = find_related_versionable_id(original_template: parent_template, record: section)
              version = SecureRandom.uuid unless version.present?
              p "    Updating versionable_id for Section: #{section.id} to #{version}"
              section.update_columns(versionable_id: version)
            end

            update_related_versionable_ids(
              original: section,
              related_records: prior_versions.map(&:sections).flatten.select { |s| s.versionable_id.nil? },
              versionable_id: section.versionable_id
            )

            section.questions.each do |question|
              unless question.versionable_id.present?
                version = find_related_versionable_id(original_template: parent_template, record: question)
                version = SecureRandom.uuid unless version.present?
                p "      Updating versionable_id for Question: #{question.id} to #{version}"
                question.update_columns(versionable_id: version)
              end

              update_related_versionable_ids(
                original: question,
                related_records: prior_versions.map(&:questions).flatten.select { |q| q.versionable_id.nil? },
                versionable_id: question.versionable_id
              )

              question.annotations.each do |annotation|
                unless annotation.versionable_id.present?
                  version = find_related_versionable_id(original_template: parent_template, record: annotation)
                  version = SecureRandom.uuid unless version.present?
                  p "      Updating versionable_id for Annotation: #{annotation.id} to #{version}"
                  annotation.update_columns(versionable_id: version)
                end

                update_related_versionable_ids(
                  original: annotation,
                  related_records: prior_versions.map(&:annotations).flatten.select { |q| q.versionable_id.nil? },
                  versionable_id: annotation.versionable_id
                )
              end
              question.question_options.each do |option|
                unless option.versionable_id.present?
                  version = find_related_versionable_id(original_template: parent_template, record: option)
                  version = SecureRandom.uuid unless version.present?
                  p "      Updating versionable_id for QuestionOption: #{option.id} to #{version}"
                  option.update_columns(versionable_id: version)
                end

                update_related_versionable_ids(
                  original: option,
                  related_records: prior_versions.map(&:question_options).flatten.select { |q| q.versionable_id.nil? },
                  versionable_id: option.versionable_id
                )
              end
            end
          end
        end
      end
    end
  end

  private

  # Renumbers/reorders the records
  def renumber_records(records:)
    return [] unless records.present? && records.any? && records.first.respond_to?(:number=)

    # Need to sort by number and id to properly sort them since there may be duplicate numbers
    sorted = records.sort { |a, b| [a.number, a.id] <=> [b.number, b.id] }
    position = 1

    # Loop through the records and renumber them
    sorted.map do |record|
      record.number = position
      position += 1
      record
    end
  end

  # Update all of the template's ccustomizations to use the specified versionable_id
  def update_related_versionable_ids(original:, related_records:, versionable_id:)
    # rubocop:disable Style/NestedTernaryOperator
    spaces = original.is_a?(Phase) ? 4 : (original.is_a?(Section) ? 6 : (original.is_a?(Question) ? 8 : 10))
    # rubocop:enable Style/NestedTernaryOperator

    related_records.each do |record|
      # Use the Number, Title and or Text to try and match the items
      text_a = [original[:number], original[:title], original[:text]].compact.join(" - ")
      text_b = [record[:number], record[:title], record[:text]].compact.join(" - ")

      if fuzzy_match?(text_a, text_b)
        p "#{' ' * spaces} ** Using versionable_id from more recent version for #{record.class.name} #{record.id}"
        record.update_columns(versionable_id: versionable_id)
      else
        p "#{' ' * spaces} * Using a new versionable_id for #{record.class.name} #{record.id}"
        record.update_columns(versionable_id: SecureRandom.uuid)
      end
    end
  end

  def find_related_versionable_id(original_template:, record:)
    # rubocop:disable Style/NestedTernaryOperator
    spaces = record.is_a?(Phase) ? 4 : (record.is_a?(Section) ? 6 : (record.is_a?(Question) ? 8 : 10))
    # rubocop:enable Style/NestedTernaryOperator
    version = nil

    begin
      original_template.send(:"#{record.class.name.downcase.pluralize}").each do |obj|
        next unless obj.versionable_id.present? && version.nil?

        # Use the Number, Title and or Text to try and match the items
        text_a = [obj[:number], obj[:title], obj[:text]].compact.join(" - ")
        text_b = [record[:number], record[:title], record[:text]].compact.join(" - ")

        if fuzzy_match?(text_a, text_b)
          p "#{' ' * spaces} ** Using versionable_id from more recent version for #{obj.class.name} #{obj.id} - #{obj.versionable_id}"
          version = obj.versionable_id
        end
      end
    rescue NoMethodError
      # this error occurs when we have a template which had no
      # questionoptions. So we can safely ignore it.
    end
    version
  end
end
# rubocop:enable Layout/LineLength, Metrics/BlockLength, Metrics/AbcSize
