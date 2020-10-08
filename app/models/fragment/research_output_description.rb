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


class Fragment::ResearchOutputDescription < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def controlled_keyword
		Fragment::ControlledKeyword.where(parent_id: id)
	end

	def contact
		Fragment::Person.where(parent_id: id).first
	end

	def dataset_id
		Fragment::Identifier.where(parent_id: id).first
	end

	def specific_data
		Fragment::SpecificData.where(parent_id: id).first
	end

	def properties
		"plan, controlled_keyword, contact, dataset_id, specific_data"
	end

	# Cited as researchOutputDescription

	def used_in
		"research_output"
	end

	def self.sti_name
		"research_output_description"
	end

end