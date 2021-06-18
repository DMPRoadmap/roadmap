# frozen_string_literal: true

namespace :templates do

  desc "Repair Templates whose phases/sections/questions/options have duplicate numbers"
  task :renumber_template_questions => :environment do
    p "Analyzing templates to determine if numbering sequences are correct."
    Template.latest_version.includes(phases: { sections: { questions: :annotations } }).each do |tmplt|

      # When testing, use this line to restrict the process to specified templates
      # next unless [586, 1144].include?(tmplt.id)

      p "Processing template #{tmplt.id} - #{tmplt.title}"
      tmplt.transaction do
        p_before = tmplt.phases.map(&:number).join(", ")
        tmplt.phases = renumber_records(records: tmplt.phases) if tmplt.phases.length > 1
        p_after = tmplt.phases.map(&:number).join(", ")

        unless p_before == p_after
          p "  Phases changed from: #{p_before} ~ to: #{p_after}"
          tmplt.phases.each { |phase| phase.save }
        end

        tmplt.phases.each do |phase|
          s_before = phase.sections.map(&:number).join(", ")
          phase.sections = renumber_records(records: phase.sections) if phase.sections.length > 1
          s_after = phase.sections.map(&:number).join(", ")

          unless s_before == s_after
            p "    Sections changed from: #{s_before} ~ to: #{s_after}"
            phase.sections.each { |section| section.save }
          end

          phase.sections.each do |section|
            q_before = section.questions.map(&:number).join(", ")
            section.questions = renumber_records(records: section.questions)
            q_after = section.questions.map(&:number).join(", ")

            unless q_before == q_after
              p "    Questions changed from: #{q_before} ~ to: #{q_after}"
              section.questions.each { |question| question.save }
            end

            section.questions.each do |question|
              next unless question.question_options.any?

              o_before = question.question_options.map(&:number).join(", ")
              question.question_options = renumber_records(records: question.question_options)
              o_after = question.question_options.map(&:number).join(", ")

              unless o_before == o_after
                p "    QuestionOptions changed from: #{o_before} ~ to: #{o_after}"
                question.question_options.each { |option| option.save }
              end
            end
          end
        end
      end
    end
  end

  desc "Repair Templates whose descendents have NIL versionable_id values"
  task :fix_templates_with_nil_versionable_ids => :environment do
    p "Attempting to repair versionable_ids"

    safe_require 'text'

    # Remove attr_readonly restrictions form these models
    Phase.attr_readonly.delete('versionable_id')
    Section.attr_readonly.delete('versionable_id')
    Question.attr_readonly.delete('versionable_id')
    Annotation.attr_readonly.delete('versionable_id')

    # Get each of the latest versions of the non-customized templates
    Template.latest_version.where(customization_of: nil)
            .includes(phases: { sections: { questions: [:annotations, :question_options] } })
            .each do |funder_template|

      # When testing, use this line to restrict the process to specified templates
      # next unless [586, 1144].include?(funder_template.id)

      # Fetch all of the prior versions of the template
      prior_versions = Template.where(customization_of: nil, family_id: funder_template.family_id)
                               .where.not(id: funder_template.id)
                               .includes(phases: { sections: { questions: [:annotations, :question_options] } })

      funder_template.phases.select { |phase| phase.versionable_id.nil? }.each do |phase|
        p "Processing Template: #{funder_template.id} - #{funder_template.title}"

        # Run all of this within a transation so that it rolls back if there is an issue!
        phase.transaction do
          phase_version = SecureRandom.uuid
          p "  Updating versionable_id for Phase: #{phase.id} to #{phase_version}"
          phase.update(versionable_id: phase_version)

          update_related_versionable_ids(
            original: phase,
            related_records: prior_versions.map(&:phases).flatten.select { |p| p.versionable_id.nil? },
            versionable_id: phase_version
          )

          phase.sections.select { |sec| sec.versionable_id.nil? }.each do |section|
            section_version = SecureRandom.uuid
            p "      Updating versionable_id for Section: #{section.id} to #{section_version}"
            section.update(versionable_id: section_version)

            update_related_versionable_ids(
              original: section,
              related_records: prior_versions.map(&:sections).flatten.select { |s| s.versionable_id.nil? },
              versionable_id: section_version
            )

            section.questions.select { |ques| ques.versionable_id.nil? }.each do |question|
              question_version = SecureRandom.uuid
              p "        Updating versionable_id for Question: #{question.id} to #{question_version}"
              question.update(versionable_id: question_version)

              update_related_versionable_ids(
                original: question,
                related_records: prior_versions.map(&:questions).flatten.select { |q| q.versionable_id.nil? },
                versionable_id: question_version
              )

              question.question_options.select { |o| o.versionable_id.nil? && o.text.present? }.each do |option|
                option_version = SecureRandom.uuid
                p "        Updating versionable_id for QuestionOption: #{option.id} to #{option_version}"
                option.update(versionable_id: option_version)

                update_related_versionable_ids(
                  original: option,
                  related_records: prior_versions.map(&:question_options).flatten.select { |q| q.versionable_id.nil? },
                  versionable_id: option_version
                )
              end

              question.annotations.select { |a| a.versionable_id.nil? && a.text.present? }.each do |annotation|
                annotation_version = SecureRandom.uuid
                p "        Updating versionable_id for Annotation: #{annotation.id} to #{annotation_version}"
                annotation.update(versionable_id: annotation_version)

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
            .includes(phases: { sections: { questions: [:annotations, :question_options] } })
            .each do |customized_template|

      # When testing, use this line to restrict the process to specified templates
      # next unless [586, 1144].include?(customized_template.id)

      customized_template.transaction do
        parent_template = Template.latest_version
                                  .where(family_id: customized_template.customization_of)
                                  .includes(phases: { sections: { questions: [:annotations, :question_options] } })
                                  .first

        customized_template.phases.each do |phase|
          p "Processing Customization: #{customized_template.id} - #{customized_template.title}"
          unless phase.versionable_id.present?
            version = find_related_versionable_id(original_template: parent_template, record: phase)
            version = SecureRandom.uuid unless version.present?
            p "  Updating versionable_id for Phase: #{phase.id} to #{version}"
            phase.update(versionable_id: version)
          end

          phase.sections.select { |s| s.versionable_id.nil? }.each do |section|
            p "Updating versionable_id for custom template section #{section.id} and its questions/options/annotations"
            unless section.versionable_id.present?
              version = find_related_versionable_id(original_template: parent_template, record: section)
              version = SecureRandom.uuid unless version.present?
              p "    Updating versionable_id for Section: #{section.id} to #{version}"
              section.update(versionable_id: version)
            end

            section.questions.each do |question|
              unless question.versionable_id.present?
                version = find_related_versionable_id(original_template: parent_template, record: question)
                version = SecureRandom.uuid unless version.present?
                p "      Updating versionable_id for Question: #{question.id} to #{version}"
                question.update(versionable_id: version)
              end

              question.annotations.each do |annotation|
                unless annotation.versionable_id.present?
                  version = find_related_versionable_id(original_template: parent_template, record: annotation)
                  version = SecureRandom.uuid unless version.present?
                  p "      Updating versionable_id for Annotation: #{annotation.id} to #{version}"
                  annotation.update(versionable_id: version)
                end
              end
              question.question_options.each do |option|
                unless option.versionable_id.present?
                  version = find_related_versionable_id(original_template: parent_template, record: option)
                  version = SecureRandom.uuid unless version.present?
                  p "      Updating versionable_id for QuestionOption: #{option.id} to #{version}"
                  option.update(versionable_id: version)
                end
              end
            end
          end
        end
      end
    end
  end

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
    spaces = original.is_a?(Phase) ? 4 : (original.is_a?(Section) ? 6 : (original.is_a?(Question) ? 8 : 10))

    related_records.each do |record|
      # Use the Number, Title and or Text to try and match the items
      text_a = [original[:number], original[:title], original[:text]].compact.join(" - ")
      text_b = [record[:number], record[:title], record[:text]].compact.join(" - ")

      if fuzzy_match?(text_a, text_b)
        p "#{" " * spaces} ** Updating versionable_id for #{record.class.name} #{record.id}"
        record.update(versionable_id: versionable_id)
      end
    end
  end

  def find_related_versionable_id(original_template:, record:)
    spaces = record.is_a?(Phase) ? 4 : (record.is_a?(Section) ? 6 : (record.is_a?(Question) ? 8 : 10))
    version = nil

    original_template.send(:"#{record.class.name.downcase.pluralize}").each do |obj|
      next unless obj.versionable_id.present? && version.nil?

      # Use the Number, Title and or Text to try and match the items
      text_a = [obj[:number], obj[:title], obj[:text]].compact.join(" - ")
      text_b = [record[:number], record[:title], record[:text]].compact.join(" - ")

      if fuzzy_match?(text_a, text_b)
        p "#{" " * spaces} ** Using versionable_id for #{obj.class.name} #{obj.id} - #{obj.versionable_id}"
        version = obj.versionable_id
      end
    end
    version
  end

end
