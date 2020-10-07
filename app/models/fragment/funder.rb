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


class Fragment::Funder < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def funder_id
		Fragment::Identifier.where(parent_id: id).first
	end

	def properties
		"plan, funder_id"
	end

	# Cited as funder

	def used_in
		"funding"
	end

	def self.sti.name
		"funder"
	end

end