# frozen_string_literal: true

meta = dmp.meta
project = dmp.project
research_outputs = dmp.plan.research_outputs.order(:display_order)

json.prettify!

json.meta             meta.get_full_fragment
json.project          project.get_full_fragment
json.contributor      format_contributors(dmp, selected_research_outputs)

json.researchOutput research_outputs do |research_output|
  research_output_fragment = research_output.json_fragment
  next unless selected_research_outputs.include?(research_output_fragment.data["research_output_id"])

  json.merge! research_output_fragment.get_full_fragment
end
json.dmp_id dmp.id
