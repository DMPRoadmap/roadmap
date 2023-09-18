# frozen_string_literal: true

module Dmpopidor
  # Customized code for ResearchOutput model
  module ResearchOutput
    def main?
      display_order.eql?(1)
    end

    # Return main research output
    def main
      plan.research_outputs.first
    end

    def common_answers?(section_id)
      answers.each do |answer|
        return true if answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) && answer.is_common
      end
      false
    end

    # Generates a new uuid
    def generate_uuid!
      new_uuid = ::ResearchOutput.unique_uuid(field_name: 'uuid')
      update_column(:uuid, new_uuid)
    end

    def get_answers_for_section(section_id)
      answers.select { |answer| answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) }
    end

    def json_fragment
      Fragment::ResearchOutput.where("(data->>'research_output_id')::int = ?", id).first
    end

    def destroy_json_fragment
      Fragment::ResearchOutput.where("(data->>'research_output_id')::int = ?", id).destroy_all
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_json_fragments(parameters = {})
      # rubocop:disable Metrics/BlockLength
      I18n.with_locale plan.template.locale do
        fragment = json_fragment
        dmp_fragment = plan.json_fragment
        contact_person = dmp_fragment.persons.first
        if fragment.nil?
          # Fetch the first question linked with a ResearchOutputDescription schema
          description_question = plan.questions.joins(:madmp_schema)
                                     .find_by(
                                       madmp_schemas: { classname: 'research_output_description' }
                                     )

          # Creates the main ResearchOutput fragment
          fragment = Fragment::ResearchOutput.create(
            data: {
              'research_output_id' => id
            },
            madmp_schema: MadmpSchema.find_by(classname: 'research_output'),
            dmp_id: dmp_fragment.id,
            parent_id: dmp_fragment.id,
            additional_info: { 
              property_name: 'researchOutput',
              hasPersonalData: parameters[:hasPersonalData]
            }
          )
          fragment_description = Fragment::ResearchOutputDescription.new(
            data: {
              'title' => title,
              'datasetId' => pid,
              'type' => output_type_description,
              'containsPersonalData' => parameters[:hasPersonalData] ? _('Yes') : _('No')
            },
            madmp_schema: MadmpSchema.find_by(name: 'ResearchOutputDescriptionStandard'),
            dmp_id: dmp_fragment.id,
            parent_id: fragment.id,
            additional_info: { property_name: 'researchOutputDescription' }
          )
          fragment_description.instantiate
          fragment_description.contact.update(
            data: {
              'person' => contact_person.present? ? { 'dbid' => contact_person.id } : nil,
              'role' => _('Data contact')
            }
          )

          if description_question.present? && plan.template.structured?
            # Create a new answer for the ResearchOutputDescription Question
            # This answer will be displayed in the Write Plan tab,
            # pre filled with the ResearchOutputDescription info
            fragment_description.answer = Answer.create(
              question_id: description_question.id,
              research_output_id: id,
              plan_id: plan.id,
              user_id: plan.users.first.id
            )
            fragment_description.save!
          end
        else
          data = fragment.research_output_description.data.merge(
            {
              'title' => title,
              'datasetId' => pid,
              'type' => output_type_description
            }
          )
          fragment.research_output_description.update(data: data)
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def has_personal_data
      json_fragment.additional_info['hasPersonalData'] || false
    end
  end
end
