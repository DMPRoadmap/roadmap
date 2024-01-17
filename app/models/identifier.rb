# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :text(65535)
#  identifiable_type    :string(255)
#  value                :string(255)      not null
#  created_at           :datetime
#  updated_at           :datetime
#  identifiable_id      :integer
#  identifier_scheme_id :integer
#
# Indexes
#
#  index_identifiers_on_identifiable_type_and_identifiable_id  (identifiable_type,identifiable_id)
#  index_identifiers_on_identifier_scheme_id_and_value         (identifier_scheme_id,value)
#  index_identifiers_on_scheme_and_type_and_id                 (identifier_scheme_id,identifiable_id,identifiable_type)
#

# Object that represents an identifier for an object
class Identifier < ApplicationRecord
  # ================
  # = Associations =
  # ================

  belongs_to :identifiable, polymorphic: true

  belongs_to :identifier_scheme, optional: true

  after_save :notify_identifiable_subscribers

  # ===============
  # = Validations =
  # ===============

  validates :value, presence: { message: PRESENCE_MESSAGE }

  validates :identifiable, presence: { message: PRESENCE_MESSAGE }

  validate :value_uniqueness_with_scheme, if: :schemed?

  validate :value_uniqueness_without_scheme, unless: :schemed?

  # ===============
  # = Scopes =
  # ===============

  def self.by_scheme_name(scheme, identifiable_type)
    scheme_id = if scheme.instance_of?(IdentifierScheme)
                  scheme.id
                else
                  IdentifierScheme.by_name(scheme).first&.id
                end
    where(identifier_scheme_id: scheme_id,
          identifiable_type: identifiable_type)
  end

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # Ensure that the value of attrs is a hash
  # TODO: evaluate this vs the Serialize approach in condition.rb
  def attrs=(hash)
    super(hash.is_a?(Hash) ? hash.to_json.to_s : '{}')
  end

  # Appends the identifier scheme's prefix to the identifier if necessary
  # For example:
  #   value   '0000-0000-0000-0001'
  #   becomes 'https://orcid.org/0000-0000-0000-0001'
  # rubocop:disable Metrics/AbcSize
  def value=(val)
    if identifier_scheme.present? &&
       identifier_scheme.identifier_prefix.present? &&
       val.to_s.strip.present? &&
       !val.to_s.start_with?(identifier_scheme.identifier_prefix) &&
       !val.to_s.start_with?('http')

      base = identifier_scheme.identifier_prefix
      base += '/' unless base.ends_with?('/')
      super("#{base}#{val.to_s.strip}")
    else
      super(val)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # ===========================
  # = Public instance methods =
  # ===========================

  # Determines the format of the identifier based on the scheme or value
  def identifier_format
    scheme = identifier_scheme&.name
    return scheme if %w[orcid ror fundref].include?(scheme)

    return 'ark' if value.include?('ark:')

    doi_regex = %r{(doi:)?[0-9]{2}\.[0-9]+/.}
    return 'doi' if value.match?(doi_regex)

    return 'url' if value.starts_with?('http')

    'other'
  end

  # Returns the value sans the identifier scheme's prefix.
  # For example:
  #   value   'https://orcid.org/0000-0000-0000-0001'
  #   becomes '0000-0000-0000-0001'
  def value_without_scheme_prefix
    return value unless identifier_scheme.present? &&
                        identifier_scheme.identifier_prefix.present?

    base = identifier_scheme.identifier_prefix
    value.gsub(base, '').sub(%r{^/}, '')
  end

  private

  # ==============
  # = VALIDATION =
  # ==============

  # Simple check used by :validate methods above
  def schemed?
    identifier_scheme.present?
  end

  # Verify the uniqueness of :value across :identifiable
  def value_uniqueness_without_scheme
    # if scheme is nil, then just unique for identifiable
    return unless Identifier.where(identifiable: identifiable, value: value).any?

    errors.add(:value, _('must be unique'))
  end

  # Ensure that the identifiable only has one identifier for the scheme
  def value_uniqueness_with_scheme
    if new_record? && Identifier.where(identifier_scheme: identifier_scheme,
                                       identifiable: identifiable).any?
      errors.add(:identifier_scheme, _('already assigned a value'))
    end
  end

  # Call the Identifiable's notify_subscribers! method directly
  def notify_identifiable_subscribers
    identifiable.notify_subscribers! if identifiable.present? && identifiable.respond_to?(:notify_subscribers!) && !new_record?
  end
end
