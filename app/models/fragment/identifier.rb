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


class Fragment::Identifier < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def properties
		"plan"
	end

	# Cited as methodsIdentifier, documentIdentifier, funderId, dmpId, relatedDocIdentifier, associatedDmpId, metadataStandardId, orgId, dataPolicyIdentifier, personId, experimentalPlanIdentifier, datasetId, technicalResourceId

	def used_in
		"data_collection, ethical_issues, funder, meta, meta, meta, metadata_standard, partner, partner, person, personal_data_issues, project, research_output_description, reused_data, technical_resource"
	end

	def self.sti_name
		"identifier"
	end

end