# frozen_string_literal: true

meta = dmp.meta
project = dmp.project
research_outputs = dmp.research_outputs

json.prettify!

json.meta             meta.get_full_fragment
json.project          project.get_full_fragment
json.contributor      format_contributors(dmp, selected_research_outputs)

json.researchOutputs research_outputs do |research_output|
  next unless selected_research_outputs.include?(research_output.data["research_output_id"])

  json.merge! research_output.get_full_fragment
end
json.dmp_id dmp.id
