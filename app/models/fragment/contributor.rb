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


class Fragment::Contributor < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def person
		Fragment::Person.where(parent_id: id).first
	end

	def properties
		"plan, person"
	end

	# Cited as contributors, contact

	def used_in
		"budget_item, data_collection, data_preservation, data_processing, data_sharing, data_storage, documentation_quality, ethical_issues, legal_issues, personal_data_issues, technical_resource_usage"
	end

	def self.sti.name
		"contributor"
	end

end