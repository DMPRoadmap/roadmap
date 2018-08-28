class AddVersioningIdToTemplates < ActiveRecord::Migration

  require 'text'


  def up
    remove_readonly_constraint_from_models

    # Get each of the funder templates...
    Template.latest_version.where(customization_of: nil)
            .includes(phases: { sections: { questions: :annotations }})
            .each do |funder_template|
      puts "Updating versionable_id for Template: #{funder_template.id}"

      funder_template.phases.each do |funder_phase|
        puts "Updating versionable_id for Phase: #{funder_phase.id}"
        funder_phase.update! versionable_id: SecureRandom.uuid

        Phase.joins(:template)
             .where(templates: { customization_of: funder_template.family_id })
             .where(number: funder_phase.number).each do |phase|

          if fuzzy_match?(phase.title, funder_phase.title)
            phase.update! versionable_id: funder_phase.versionable_id
          end
        end

        funder_phase.sections.each do |funder_section|
          puts "Updating versionable_id for Section: #{funder_section.id}"
          funder_section.update! versionable_id: SecureRandom.uuid

          Section.joins(:template).where(templates: {
            customization_of: funder_template.family_id
            }).each do |section|

            # Prefix the match text with the number. This will make it easier to match
            # Sections where the number hasn't changed
            text_a = "#{section.number} - #{section.description}"
            text_b = "#{funder_section.number} - #{funder_section.description}"
            if fuzzy_match?(text_a, text_b)
              section.update! versionable_id: funder_section.versionable_id
            end
          end

          funder_section.questions.each do |funder_question|
            puts "Updating versionable_id for Question: #{funder_question.id}"

            funder_question.update! versionable_id: SecureRandom.uuid

            Question.joins(:template).where(templates: {
              customization_of: funder_template.family_id
              }).each do |question|

              # Prefix the match text with the number. This will make it easier to match
              # Questions where the number hasn't changed
              text_a = "#{question.number} - #{question.text}"
              text_b = "#{funder_question.number} - #{funder_question.text}"

              if fuzzy_match?(text_a, text_b)
                question.update! versionable_id: funder_question.versionable_id
              end
            end

            funder_question.annotations.each do |funder_annotation|
              puts "Updating versionable_id for Annotation: #{funder_annotation.id}"

              funder_annotation.update! versionable_id: SecureRandom.uuid

              Annotation.joins(:template).where(templates: {
                customization_of: funder_template.family_id,
              }).where(type: funder_annotation.type).each do |ann|

                if fuzzy_match?(ann.text, funder_annotation.text)
                  ann.update! versionable_id: funder_annotation.versionable_id
                end
              end
            end
          end
        end
      end
    end

    # Add versionable_id to any customized Sections...
    Section.joins(:template)
           .includes(questions: :annotations)
           .where(templates: { id: Template.latest_version.ids })
           .where(versionable_id: nil, modifiable: true).each do |section|

      section.update! versionable_id: SecureRandom.uuid

      section.questions.each do |question|
        question.update! versionable_id: SecureRandom.uuid
        question.annotations.each do |annotation|
          annotation.update! versionable_id: SecureRandom.uuid
        end
      end
    end
  end

  def down
    Phase.update_all versionable_id: nil
    Section.update_all versionable_id: nil
    Question.update_all versionable_id: nil
    Annotation.update_all versionable_id: nil
  end

  private

  def fuzzy_match?(text_a, text_b, min = 3)
    Text::Levenshtein.distance(text_a, text_b) <= min
  end

  def remove_readonly_constraint_from_models
    Phase.attr_readonly.delete('versionable_id')
    Section.attr_readonly.delete('versionable_id')
    Question.attr_readonly.delete('versionable_id')
    Annotation.attr_readonly.delete('versionable_id')
  end

end
