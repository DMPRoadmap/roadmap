module Identifiable

  extend ActiveSupport::Concern

  included do

    # ================
    # = Associations =
    # ================

    has_many :identifiers, as: :identifiable, dependent: :destroy

    # =====================
    # = Nested Attributes =
    # =====================

    accepts_nested_attributes_for :identifiers

    # =================
    # = Class Methods =
    # =================

    # Expects an array of `identifier_scheme.name` and `identifier.value`
    #   [{ name: "fundref", value: "12345" }, { name: "ror", value: "abc"} ]
    # Returns an instance of the model
    def self.from_identifiers(array:)
      return nil unless array.present? && array.any?

      id = nil
      array.uniq.each do |hash|
        next unless hash[:name].present? && hash[:value].present?

        # Get the IdentifierScheme, skip if it does not exist
        scheme = IdentifierScheme.by_name(hash[:name].downcase)
        next unless scheme.present?

        # Look for the Identifier and finish up once found
        id = Identifier.where(identifier_scheme: scheme, value: hash[:value],
                              identifiable_type: name).first
        break if id.present?
      end

      id.present? ? id.identifiable : nil
    end

    # ====================
    # = Instance Methods =
    # ====================

    # gets the identifier for the scheme
    def identifier_for_scheme(scheme:)
      scheme = IdentifierScheme.by_name(scheme.downcase).first if scheme.is_a?(String)
      identifiers.select { |id| id.identifier_scheme == scheme }.last
    end

    # Combines the existing identifiers with the new ones
    def consolidate_identifiers!(array:)
      return false unless array.present? && array.is_a?(Array)

      array.each do |id|
        next unless id.is_a?(Identifier) && id.value.present?

        # If the identifier already exists then keep it
        current = identifier_for_scheme(scheme: id.identifier_scheme)
        next if current.present?

        # Otherwise add it
        id.identifiable = self
        identifiers << id
      end
      true
    end

  end

end
