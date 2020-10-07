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


class Fragment::DocumentationQuality < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def data_organization
		Fragment::DataOrganization.where(parent_id: id)
	end

	def metadata_standard
		Fragment::MetadataStandard.where(parent_id: id)
	end

	def quality_assurance_method
		Fragment::QualityAssuranceMethod.where(parent_id: id)
	end

	def contributors
		Fragment::Contributor.where(parent_id: id)
	end

	def cost
		Fragment::Cost.where(parent_id: id)
	end

	def properties
		"plan, data_organization, metadata_standard, quality_assurance_method, contributors, cost"
	end

	# Cited as documentationQuality

	def used_in
		"research_output"
	end

	def self.sti.name
		"documentation_quality"
	end

end