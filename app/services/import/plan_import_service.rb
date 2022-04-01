# frozen_string_literal: true

module Import
  # Service used to import a plan from a JSON document
  class PlanImportService
    class << self
      def import(plan, json_data, format)
        dmp_fragment = plan.json_fragment
        begin
          dmp = JSON.parse(json_data)

          dmp = Import::Converters::RdaToStandard.convert(dmp['dmp']).deep_stringify_keys if format.eql?('rda')

          dmp_fragment.raw_import(
            dmp.slice('meta', 'project', 'budget'), MadmpSchema.find_by(name: 'DMPStandard')
          )
          Import::PlanImportService.handle_research_outputs(plan, dmp['researchOutput'])
        rescue JSON::ParserError
          flash.now[:alert] = 'File should contain JSON'
        end
      end

      def handle_research_outputs(plan, research_outputs)
        research_outputs.each_with_index do |ro_data, idx|
          research_output = plan.research_outputs.create(
            abbreviation: "Research Output #{idx + 1}",
            title: ro_data['researchOutputDescription']['title'],
            is_default: idx.eql?(0),
            order: idx + 1
          )
          ro_frag = research_output.json_fragment
          import_research_output(ro_frag, ro_data, plan)
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def import_research_output(research_output_fragment, research_output_data, plan)
        dmp_id = research_output_fragment.dmp_id
        research_output_data.each do |prop, content|
          next if prop.eql?('research_output_id')

          schema_prop = research_output_fragment.madmp_schema.schema['properties'][prop]
          next if schema_prop&.dig('type').nil?

          if research_output_fragment.data[prop].nil?
            # Fetch the associated question
            associated_question = plan.questions.joins(:madmp_schema).find_by(madmp_schema_id: schema_prop['schema_id'])
            next if associated_question.nil?

            fragment = MadmpFragment.new(
              dmp_id: dmp_id,
              parent_id: research_output_fragment.id,
              madmp_schema: associated_question.madmp_schema,
              additional_info: { 'property_name' => prop }
            )
            fragment.classname = schema_prop['class']
            next unless associated_question.present? && plan.template.structured?

            # Create a new answer for the question associated to the fragment
            fragment.answer = Answer.create(
              question_id: associated_question.id,
              research_output_id: research_output_fragment.research_output_id,
              plan_id: plan.id, user_id: plan.owner.id
            )
            fragment.save!
          else
            fragment = MadmpFragment.find(research_output_fragment.data[prop]['dbid'])
          end
          fragment.raw_import(content, fragment.madmp_schema, fragment.id)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
