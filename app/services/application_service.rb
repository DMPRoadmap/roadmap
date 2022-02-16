# frozen_string_literal: true

# Generic methods used throughout the site
class ApplicationService
  class << self
    # Returns either the name specified in dmproadmap.rb initializer or
    # the Rails application name
    def application_name
      default = Rails.application.class.name.split('::').first
      Rails.configuration.x.application.fetch(:name, default)
    end

    # Use the Rails secret key to encrypt information. Some typical use cases for this
    # would be to store information in the browser session or to encrypt sensitive data
    # before inserting it into the DB
    #
    # Warning: be cautious using this to encrypt data persisted to a DB because it is
    #          reliant on the Rails secret key base which can change!
    def encrypt(payload:)
      return nil unless payload.present?

Rails.logger.warn "ApplicationService - payload: #{payload.inspect}"
Rails.logger.warn "ApplicationService ObjID: #{Rails.application.credentials.secret_key_base}"

      payload = payload.to_json if payload.respond_to?(:to_json)
      crypto.encrypt_and_sign(payload)
    rescue StandardError => e
      Rails.logger.error "ApplicationService.encrypt - #{e.message}"
      nil
    end

    # Use the Rails secret key to decrypt information.
    def decrypt(payload:)
      return nil unless payload.present?

      decrypted = crypto.decrypt_and_verify(payload)
      JSON.parse(decrypted)
    rescue JSON::ParserError
      # If JSON wasn't encrpyted then just return the decrypted value
      decrypted
    rescue StandardError => e
      Rails.logger.error "ApplicationService.encrypt - #{e.message}"
    end

    private

    # Generate a new encryptor using the Rails secret key base
    def crypto
      ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base)
    end
  end
end
