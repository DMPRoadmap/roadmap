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

  include DeviseInvitable::Inviter

  extend UniqueRandom

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  has_many :plans

  # If the Client_id or client_secret are nil generate them
  attribute :client_id, :string, default: -> { unique_random(field_name: "client_id") }
  attribute :client_secret, :string,
            default: -> { unique_random(field_name: "client_secret") }

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { case_sensitive: false,
                                 message: UNIQUENESS_MESSAGE }

  validates :contact_email, presence: { message: PRESENCE_MESSAGE },
                            email: { allow_nil: false }

  validates :client_id, presence: { message: PRESENCE_MESSAGE }
  validates :client_secret, presence: { message: PRESENCE_MESSAGE }

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

  # Verify that the incoming secret matches
  def authenticate(secret:)
    client_secret == secret
  end

  # Generate UUIDs for the client_id and client_secret
  def generate_credentials
    self.client_id = ApiClient.unique_random(field_name: "client_id")
    self.client_secret = ApiClient.unique_random(field_name: "client_secret")
  end

end
