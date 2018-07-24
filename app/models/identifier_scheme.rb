# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  logo_url         :text
#  name             :string
#  user_landing_url :text
#  created_at       :datetime
#  updated_at       :datetime
#

class IdentifierScheme < ActiveRecord::Base
  has_many :user_identifiers
  has_many :users, through: :user_identifiers
  
  validates :name, uniqueness: {message: _("must be unique")}, presence: {message: _("can't be blank")}
end
