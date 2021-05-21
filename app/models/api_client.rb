# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id              :integer          not null, primary key
#  name            :string,          not null
#  homepage        :string
#  contact_name    :string
#  contact_email   :string,          not null
#  client_id       :string,          not null
#  client_secret   :string,          not null
#  last_access     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  org_id          :integer
#  redirect_uri    :text
#  callback_uri    :string
#  callback_method :string
#  scopes          :string
#  confidential    :boolean,         default: true
#  trusted         :boolean,         default: false
#  user_id         :integer
#  logo_name       :string
#  logo_uid        :string
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

  extend Dragonfly::Model::Validations
  extend UniqueRandom

  enum callback_methods: %i[put post patch]

  LOGO_FORMATS = %w[jpeg png gif jpg bmp svg].freeze

  dragonfly_accessor :logo

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  # TODO: Make this required once we've transitioned away from the old :contact_name + :contact_email
  belongs_to :user, optional: true

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

  validates_property :format, of: :logo, in: LOGO_FORMATS,
                      message: _("must be one of the following formats: %{formats}") % {
                        formats: LOGO_FORMATS.join(", ")
                      }

  validates_size_of :logo, maximum: 500.kilobytes, message: _("can't be larger than 500KB")

  # =============
  # = Callbacks =
  # =============

  before_validation :ensure_scopes

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

  # Returns the scopes defined in the Doorkeeper config
  def available_scopes
    (Doorkeeper.config.default_scopes.to_a << Doorkeeper.config.optional_scopes.to_a).flatten.uniq
  end

  private

  # Set the scopes
  def ensure_scopes
    self.scopes = available_scopes.sort { |a, b| a <=> b }.join(" ")
  end

end
