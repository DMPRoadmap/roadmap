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


class Fragment::EthicalIssues < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def document_identifier
		Fragment::Identifier.where(parent_id: id)
	end

	def contact
		Fragment::Contributor.where(parent_id: id).first
	end

	def properties
		"plan, document_identifier, contact"
	end

	# Cited as ethicalIssues

	def used_in
		"research_output"
	end

	def self.sti_name
		"ethical_issues"
	end

end