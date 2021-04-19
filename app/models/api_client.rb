# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id             :integer          not null, primary key
#  name           :string,          not null
#  homepage       :string
#  contact_name   :string
#  contact_email  :string,          not null
#  client_id      :string,          not null
#  client_secret  :string,          not null
#  last_access    :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#
# Indexes
#
#  index_api_clients_on_name     (name)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)

class ApiClient < ApplicationRecord

  self.table_name = "oauth_applications"

  include DeviseInvitable::Inviter
  include Subscribable
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include ::Doorkeeper::Models::Scopes

  extend UniqueRandom

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  # Access Tokens are created when an ApiClient authenticates themselves and is then used instead
  # of credentials when calling the API.
  has_many :access_tokens, class_name: "::Doorkeeper::AccessToken",
                           foreign_key: :application_id,
                           dependent: :delete_all

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { case_sensitive: false,
                                 message: UNIQUENESS_MESSAGE }

  validates :contact_email, presence: { message: PRESENCE_MESSAGE },
                            email: { allow_nil: false }

  # =================
  # = Compatibility =
  # =================

  # These aliases provide backward compatibility for API V1
  alias_attribute :client_id, :uid
  alias_attribute :client_secret, :secret

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # Ensure the name is always saved as lowercase
  # TODO: do we want to add this as a validation as well?
  def name=(value)
    super(value&.downcase)
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # Override the to_s method to keep the id and secret hidden
  def to_s
    name
  end

end
