require 'set'
namespace :madmpopidor do

  desc "Initialize Dmp, Project, Meta & ResearchOutputs JSON fragments for the ancient plans"
  task initialize_plan_fragments: :environment do
    Plan.all.each do |plan|
        if plan.json_fragment.nil?
            plan.create_plan_fragments()
        end

        plan.research_outputs.each do |research_output|
            unless research_output.nil?
                if research_output.json_fragment.nil?
                    research_output.create_or_update_fragments()
                end
            end
        end
    end
  end

  desc "Initialize the template locale to the default language of the application"
  task initialize_template_locale: :environment do
    languages = Language.all
    Template.all.each do |template|
        if languages.find_by(abbreviation: template.locale).nil?
            template.update(locale: Language.default.abbreviation)
        end
    end
  end

end