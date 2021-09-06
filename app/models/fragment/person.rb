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
    contributors_list = self.contributors
    roles_list = []
    ro_contact_role = nil
    if selected_research_outputs.present?
      contributors_list = contributors_list
                          .select do |c|
                            c.research_output_id.nil? || selected_research_outputs.include?(c.research_output_id)
                          end
    end
    # This part of the code whecks if the contributor is a data contact for a research output
    # if so, the role will be displayed once as a concatenation of the research output abbreviation
    # Ex: Data contact (RO1, RO2)
    contributors_list.each_with_index do |c, index|
      if c.parent&.classname.eql?("research_output_description")
        ro = ::ResearchOutput.find(c.research_output_id)
        ro_contact_role = "#{c.data['role']} (" if ro_contact_role.nil?
        ro_contact_role += "#{ro.abbreviation}, "
      else
        roles_list.push(c.data["role"])
      end
    end
    roles_list.push(ro_contact_role.chomp(", ") + ")") if ro_contact_role.present?
    return roles_list.compact.sort
  end

  def contributors
    Fragment::Contributor.where("(data->'person'->>'dbid')::int = ?", id)
  end

  def self.sti_name
    "person"
  end

end
