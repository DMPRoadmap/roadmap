# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_access_tokens
#
#  id                    :bigint(8)        not null, primary key
#  access_token          :string(255)      not null
#  expires_at            :datetime
#  external_service_name :string(255)      not null
#  refresh_token         :string(255)
#  revoked_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :bigint(8)        not null
#
# Indexes
#
#  index_external_api_access_tokens_on_expires_at             (expires_at)
#  index_external_api_access_tokens_on_external_service_name  (external_service_name)
#  index_external_api_access_tokens_on_user_id                (user_id)
#  index_external_tokens_on_user_and_service                  (user_id,external_service_name)
#

# Model representing an OAuth access token to an external system like ORCID
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
        .where('revoked_at IS NULL OR revoked_at > ?', Time.zone.now)
        .where('expires_at IS NULL OR expires_at > ?', Time.zone.now)
        .first
    end

    # Generates an instance based on the contents of an OmniAuth hash
    # rubocop:disable Metrics/AbcSize
    def from_omniauth(user:, service:, hash:)
      return nil unless user.is_a?(User) &&
                        service.present? &&
                        hash.present?

      token_hash = hash.fetch(:credentials, {})
      return nil if token_hash[:token].blank?

      # revoke any existing tokens for the user + scheme
      where(user: user, external_service_name: service.downcase).find_each(&:revoke!)

      # add the token for the user + scheme
      expiry_time = (Time.zone.now + token_hash[:expires_at].to_i.seconds).utc if token_hash[:expires_at].present?
      new(
        user: user,
        external_service_name: service.downcase,
        access_token: token_hash[:token],
        refresh_token: token_hash[:refresh_token],
        expires_at: expiry_time
      )
    end
    # rubocop:enable Metrics/AbcSize
  end

  # ====================
  # = Instance Methods =
  # ====================

  def revoke!
    update(revoked_at: Time.zone.now)
  end

  def active?
    (revoked_at.nil? || revoked_at > Time.zone.now) && expires_at > Time.zone.now
  end

  private

  # Validator to prevent multiple active access tokens for a user + service
  def one_active_token
    return true if self.class.for_user_and_service(user: user, service: external_service_name).nil?

    errors.add(:access_token, _('only one active access token allowed per user / service'))
  end
end
