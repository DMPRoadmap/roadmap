# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_access_tokens
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  external_service_name  :string
#  access_token           :string
#  refresh_token          :string
#  expires_at             :datetime
#  revoked_at             :datetime
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_external_api_access_tokens_on_external_service_name  (external_service_name)
#  index_external_api_access_tokens_on_expires_at             (expires_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)

class ExternalApiAccessToken < ApplicationRecord
  # This class works in conjunction with Devise OmniAuth providers. If a provider returns an
  # acess token along with the :uid, then the access token gets stored in this table. It expects
  # the following to be passed back as part of the "omniauth.auth" response:
  #
  # "credentials": {
  #   "token": "c805b0b6-d66f-46ed-b2f2-250b7610c78b",
  #   "refresh_token": "6de08c52-74dd-4a7b-aae7-c2a6795dbb3d",
  #   "expires_at": 2250680850,
  #   "expires": true
  # }
  #
  # Note that the app/controllers/users/omniauth_callbacks_controller.rb creates these records. They
  # are 'revoked' when the User 'disconnects' themselves from the integration on their Profile page.
  #
  # The lib/tasks/utils/housekeeping.rb has a task called "cleanup_external_api_access_tokens" that
  # will delete any revoked or expired tokens
  #

  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :user

  # ===============
  # = Validations =
  # ===============

  validates :user, :external_service_name, :access_token, presence: { message: PRESENCE_MESSAGE }

  # A User may only have one active token per external service!
  validate :one_active_token, on: %i[create]

  # =================
  # = Class Methods =
  # =================

  class << self

    # Fetched the active access token for the specified User and External API service
    def for_user_and_service(user:, service:)
      where(user: user, external_service_name: service)
        .where("revoked_at IS NULL OR revoked_at > ?", Time.now)
        .where("expires_at IS NULL OR expires_at > ?", Time.now)
        .first
    end

    # Generates an instance based on the contents of an OmniAuth hash
    def from_omniauth(user:, service:, hash:)
      return nil unless user.is_a?(User) &&
                        service.present? &&
                        hash.present?

      token_hash = hash.fetch(:credentials, {})
      return nil unless token_hash[:token].present?

      # revoke any existing tokens for the user + scheme
      where(user: user, external_service_name: service.downcase).each(&:revoke!)

      # add the token for the user + scheme
      expiry_time = (Time.now + token_hash[:expires_at].to_i.seconds).utc if token_hash[:expires_at].present?
      new(
        user: user,
        external_service_name: service.downcase,
        access_token: token_hash[:token],
        refresh_token: token_hash[:refresh_token],
        expires_at: expiry_time
      )
    end

  end

  # ====================
  # = Instance Methods =
  # ====================

  def revoke!
    update(revoked_at: Time.now)
  end

  def active?
    (revoked_at.nil? || revoked_at > Time.now) && expires_at > Time.now
  end

  private

  # Validator to prevent multiple active access tokens for a user + service
  def one_active_token
    return true if self.class.for_user_and_service(user: user, service: external_service_name).nil?

    errors.add(:access_token, _("only one active access token allowed per user / service"))
  end

end