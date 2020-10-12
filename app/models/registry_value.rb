# == Schema Information
#
# Table name: registry_values
#
#  id         :integer          not null, primary key
#  data       :json             
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  registry_id :integer
#

class RegistryValue < ActiveRecord::Base

  # ================
  # = Associations =
  # ================
  
  belongs_to :registry

end