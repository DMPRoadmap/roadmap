# == Schema Information
#
# Table name: madmp_fragments

#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  madmp_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer

# Indexes

#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)

class Fragment::Person < MadmpFragment

  def roles(selected_research_outputs = nil)
    if selected_research_outputs.nil?
      contributors_list = Fragment::Contributor.where("(data->'person'->>'dbid')::int = ?", id)
    else
      contributors_list = Fragment::Contributor.where("(data->'person'->>'dbid')::int = ?", id)
                                               .select do |c|
                                                 c.research_output_id.nil? || selected_research_outputs.include?(c.research_output_id)
                                               end
    end
    contributors_list.map do |c|
      if c.parent&.classname.eql?("research_output_description")
        ro = ::ResearchOutput.find(c.research_output_id)
        "#{c.data['role']} (#{ro.abbreviation})"
      else
        c.data["role"]
      end
    end.compact
  end

  def contributors
    Fragment::Contributor.where("(data->'person'->>'dbid')::int = ?", id)
  end

  def self.sti_name
    "person"
  end

end
