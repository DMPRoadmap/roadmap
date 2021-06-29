# frozen_string_literal: true

namespace :versioning do

  desc "Repair Templates whose phases/sections/questions/options have duplicate numbers"
  task :renumber_template_questions => :environment do
    Template.latest_version.includes(phases: { sections: { questions: :annotations } }).each do |tmplt|
      tmplt.transaction do
        tmplt.phases = renumber_records(records: tmplt.phases) if tmplt.phases.length > 1
        tmplt.save

        tmplt.phases.each do |phase|
          phase.sections = renumber_records(records: phase.sections) if phase.sections.length > 1
          phase.save

          phase.sections.each do |section|
            section.questions = renumber_records(records: section.questions)
            section.save

            section.questions.each do |question|
              question.question_options = renumber_records(records: question.question_options)
              question.save
            end
          end
        end
      end
    end
  end

  desc "Repair Templates whose descendents have NIL versionable_id values"
  task :fix_templates_with_nil_versionable_ids => :environment do
    Rake::Task["versioning:renumber_template_questions"].execute

    safe_require 'text'

    # Remove attr_readonly restrictions form these models
    Phase.attr_readonly.delete('versionable_id')
    Section.attr_readonly.delete('versionable_id')
    Question.attr_readonly.delete('versionable_id')
    Annotation.attr_readonly.delete('versionable_id')

    # Get each of the funder templates...
    Template.latest_version.where(customization_of: nil)
            .includes(phases: { sections: { questions: [:annotations, :question_options] } })
            .each do |funder_template|

      customizations = Template.where(customization_of: funder_template.family_id)
                               .includes(phases: { sections: { questions: [:annotations, :question_options] } })

      funder_template.phases.select { |phase| phase.versionable_id.nil? }.each do |phase|
        p "Processing Funder Template: #{funder_template.id} - #{funder_template.title}"

        # Run all of this within a transation so that it rolls back if there is an issue!
        phase.transaction do
          phase_version = SecureRandom.uuid
          p "  Updating versionable_id for Phase: #{phase.id} to #{phase_version}"
          phase.update(versionable_id: phase_version)

          update_customization_versionable_ids(
            original: phase,
            customizations: customizations.map(&:phases).select { |p| p.versionable_id.nil? },
            versionable_id: phase_version
          )

          phase.sections.select { |sec| sec.versionable_id.nil? }.each do |section|
            section_version = SecureRandom.uuid
            p "      Updating versionable_id for Section: #{section.id} to #{section_version}"
            section.update(versionable_id: section_version)

            update_customization_versionable_ids(
              original: section,
              customizations: customizations.map(&:sections).select { |s| s.versionable_id.nil? },
              versionable_id: section_version
            )

            section.questions.select { |ques| ques.versionable_id.nil? }.each do |question|
              question_version = SecureRandom.uuid
              p "        Updating versionable_id for Question: #{question.id} to #{question_version}"
              question.update!(versionable_id: question_version)

              update_customization_versionable_ids(
                original: question,
                customizations: customizations.map(&:questions).select { |q| q.versionable_id.nil? },
                versionable_id: question_version
              )

              question.question_options.select { |o| o.versionable_id.nil? && o.text.present? }.each do |option|
                option_version = SecureRandom.uuid
                p "        Updating versionable_id for QuestionOption: #{option.id} to #{option_version}"
                option.update!(versionable_id: option_version)

                update_customization_versionable_ids(
                  original: option,
                  customizations: customizations.map(&:question_options).select { |q| q.versionable_id.nil? },
                  versionable_id: option_version
                )
              end

              question.annotations.select { |a| a.versionable_id.nil? && a.text.present? }.each do |annotation|
                annotation_version = SecureRandom.uuid
                p "        Updating versionable_id for Annotation: #{annotation.id} to #{annotation_version}"
                annotation.update!(versionable_id: annotation_version)

                update_customization_versionable_ids(
                  original: annotation,
                  customizations: customizations.map(&:annotations).select { |q| q.versionable_id.nil? },
                  versionable_id: annotation_version
                )
              end
            end
          end
        end
      end
    end

    # Add versionable_id to any customized Sections...
    Section.joins(:template).includes(questions: [:annotations, :question_options])
           .where(templates: { id: Template.latest_version.ids })
           .where(versionable_id: nil, modifiable: true).each do |section|
      section.transaction do
        p "Updating versionable_id for custom template section #{section.id} and its questions/options/annotations"
        section.update(versionable_id: SecureRandom.uuid)

        section.questions.each do |question|
          question.update(versionable_id: SecureRandom.uuid)
          question.annotations.each do |annotation|
            annotation.update(versionable_id: SecureRandom.uuid)
          end
          question.question_options.each do |option|
            option.update(versionable_id: SecureRandom.uuid)
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
  def update_customization_versionable_ids(original:, customizations:, versionable_id:)
    customizations.each do |record|
      # Use the Number, Title and or Text to try and match the items
      text_a = [original&.number, original&.title, original&.text].join(" - ")
      text_b = [record&.number, record&.title, record&.text].join(" - ")
      if fuzzy_match?(text_a, text_b)
        p "    Updating versionable_id for #{record.class.name} Customization #{record.id}"
        record.update(versionable_id: versionable_id)
      end
    end
  end

end
