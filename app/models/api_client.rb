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

class ApiClient < ActiveRecord::Base

  include DeviseInvitable::Inviter
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  # TODO: Enable `optional: true` when merged into Rails 5 codebase
  belongs_to :org # , optional: true

  has_many :plans

  # If the Client_id or client_secret are nil generate them
  before_validation :generate_credentials,
                    if: Proc.new { |c| c.client_id.blank? || c.client_secret.blank? }

  # Force the name to downcase
  before_save :name_to_downcase

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
    self.client_id = SecureRandom.uuid
    self.client_secret = SecureRandom.uuid
  end

  private

  def name_to_downcase
    self.name = self.name.downcase
  end

end
