# frozen_string_literal: true

module Import
  # Service used to import a plan from a JSON document
  class PlanImportService
    class << self
      def import(plan, json_data, import_format)
        dmp_fragment = plan.json_fragment
        if import_format.eql?('rda')
          dmp = Import::Converters::RdaToStandardConverter.convert(json_data['dmp'])
          contributors = Import::Converters::RdaToStandardConverter.convert_contributors(json_data.dig('dmp',
                                                                                                       'contributor'))
          handle_contributors(dmp_fragment, contributors)
        else
          dmp = json_data
        end
        dmp_template_name = plan.template.research_entity? ? 'DMPResearchEntity' : 'DMPResearchProject'
        dmp_fragment.raw_import(
          dmp.slice('meta', 'project', 'research_entity', 'budget'), MadmpSchema.find_by(name: dmp_template_name)
        )
        Import::PlanImportService.handle_research_outputs(plan, dmp['researchOutput'])
      end

      def handle_research_outputs(plan, research_outputs)
        research_outputs.each_with_index do |ro_data, idx|
          research_output = plan.research_outputs.create(
            abbreviation: "Research Output #{idx + 1}",
            title: ro_data['researchOutputDescription']['title'],
            is_default: idx.eql?(0),
            display_order: idx + 1
          )
          ro_frag = research_output.json_fragment
          import_research_output(ro_frag, ro_data, plan)
        end
      end

      def handle_contributors(dmp_fragment, contributors)
        schema = MadmpSchema.find_by(name: 'PersonStandard')
        contributors.each do |contributor|
          next if MadmpFragment.fragment_exists?(contributor, schema, dmp_fragment.id, nil)

          Fragment::Person.create!(
            data: contributor,
            dmp_id: dmp_fragment.id,
            madmp_schema: schema,
            additional_info: { property_name: 'person' }
          )
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
              dmp_id:,
              parent_id: research_output_fragment.id,
              madmp_schema: associated_question.madmp_schema,
              additional_info: { 'property_name' => prop }
            )
            fragment.classname = associated_question.madmp_schema.classname
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

      def validate(json_data, import_format)
        return [_('Invalid JSON data')] if json_data.nil?
        return [_('Invalid format')] unless %w[rda standard].include?(import_format)

        errs = []
        if import_format.eql?('rda')
          return [_('File should begin with :dmp property')] unless json_data['dmp'].present?

          errs = Import::Validators::Rda.validation_errors(json: json_data['dmp'].deep_symbolize_keys)
        else
          errs = Import::Validators::Standard.validation_errors(json: json_data)
        end
        errs
      end
    end
  end
end
