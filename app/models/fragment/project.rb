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


class Fragment::Project < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def funding
		Fragment::Funding.where(parent_id: id)
	end

	def partner
		Fragment::Partner.where(parent_id: id)
	end

	def experimental_plan_identifier
		Fragment::Identifier.where(parent_id: id).first
	end

	def principal_investigator
		Fragment::Person.where(parent_id: id).first
	end

	def properties
		"plan, funding, partner, experimental_plan_identifier, principal_investigator"
	end

	# Cited as project

	def used_in
		"dmp"
	end

	def self.sti.name
		"project"
	end

end