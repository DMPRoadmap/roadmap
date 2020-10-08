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


class Fragment::Meta < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def contact
		Fragment::Person.where(parent_id: id).first
	end

	def dmp_id
		Fragment::Identifier.where(parent_id: id).first
	end

	def license
		Fragment::License.where(parent_id: id).first
	end

	def related_doc_identifier
		Fragment::Identifier.where(parent_id: id)
	end

	def associated_dmp_id
		Fragment::Identifier.where(parent_id: id)
	end

	def properties
		"plan, contact, dmp_id, license, related_doc_identifier, associated_dmp_id"
	end

	# Cited as meta

	def used_in
		"dmp"
	end

	def self.sti_name
		"meta"
	end

end