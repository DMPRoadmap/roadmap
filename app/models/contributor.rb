# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id           :integer          not null, primary key
#  firstname    :string
#  surname      :string
#  email        :string
#  phone        :string
#  org_id       :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_contributors_on_id      (id)
#  index_contributors_on_email   (email)
#  index_contributors_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)

class Contributor < ActiveRecord::Base

  include ValidationMessages

  # ================
  # = Associations =
  # ================

  # TODO: uncomment the 'optional' bit after the Rails 5 migration. Rails 5+ will
  #       NOT allow nil values in a belong_to field!
  belongs_to :org #, optional: true

  has_many :plans_contributors, dependent: :destroy

  has_many :plans, through: :plans_contributors

  has_many :identifiers, as: :identifiable, dependent: :destroy

  # ===============
  # = Validations =
  # ===============

  validates :email, email: { null: true }

  # ===============
  # Instance Methods
  # ===============

  def name(last_first: false)
    names = [firstname, surname]
    last_first ? names.reverse.join(", ") : names.join(" ")
  end

end
