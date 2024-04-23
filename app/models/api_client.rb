# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id            :integer          not null, primary key
#  client_secret :string           not null
#  contact_email :string           not null
#  contact_name  :string
#  description   :string
#  homepage      :string
#  last_access   :datetime
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#  org_id        :integer
#
# Indexes
#
#  index_api_clients_on_name  (name)
#

# Object that represents an external system
class ApiClient < ApplicationRecord
  include DeviseInvitable::Inviter

  extend UniqueRandom

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  has_many :roles, class_name: 'ApiClientRole', dependent: :destroy
  has_many :plans, through: :roles
  has_many :madmp_schemas

  # If the Client_id or client_secret are nil generate them
  attribute :client_id, :string, default: -> { unique_random(field_name: 'client_id') }
  attribute :client_secret, :string,
            default: -> { unique_random(field_name: 'client_secret') }

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
    self.client_id = ApiClient.unique_random(field_name: 'client_id')
    self.client_secret = ApiClient.unique_random(field_name: 'client_secret')
  end
end
