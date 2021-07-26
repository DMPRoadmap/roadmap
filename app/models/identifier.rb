# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :text
#  identifiable_type    :string
#  value                :string           not null
#  created_at           :datetime
#  updated_at           :datetime
#  identifiable_id      :integer
#  identifier_scheme_id :integer          not null
#
# Indexes
#
#  index_identifiers_on_identifiable_type_and_identifiable_id  (identifiable_type,identifiable_id)
#
class Identifier < ActiveRecord::Base

  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :identifiable, polymorphic: true

  # TODO: uncomment 'optional: true' once we are on Rails 5
  belongs_to :identifier_scheme #, optional: true

  # ===============
  # = Validations =
  # ===============

  validates :value, presence: { message: PRESENCE_MESSAGE }

  validates :identifiable, presence: { message: PRESENCE_MESSAGE }

  validate :value_uniqueness_with_scheme, if: :has_scheme?

  validate :value_uniqueness_without_scheme, unless: :has_scheme?

  # ===============
  # = Scopes =
  # ===============

  def self.by_scheme_name(scheme, identifiable_type)
    scheme_id = scheme.instance_of?(IdentifierScheme) ? scheme.id : IdentifierScheme.by_name(scheme).first&.id
    where(identifier_scheme_id: scheme_id,
          identifiable_type: identifiable_type)
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  def attrs=(hash)
    write_attribute(:attrs, (hash.is_a?(Hash) ? hash.to_json.to_s : "{}"))
  end

  # Determines the format of the identifier based on the scheme or value
  def identifier_format
    scheme = identifier_scheme&.name
    return scheme if %w[orcid ror fundref].include?(scheme)

    return "ark" if value.include?("ark:")

    doi_regex = /(doi:)?[0-9]{2}\.[0-9]+\/./
    return "doi" if value =~ doi_regex

    return "url" if value.starts_with?("http")

    "other"
  end

  # Returns the value sans the identifier scheme's prefix.
  # For example:
  #   value   'https://orcid.org/0000-0000-0000-0001'
  #   becomes '0000-0000-0000-0001'
  def value_without_scheme_prefix
    return value unless identifier_scheme.present? &&
                        identifier_scheme.identifier_prefix.present?

    base = identifier_scheme.identifier_prefix
    value.gsub(base, "").sub(%r{^\/}, "")
  end

  # Appends the identifier scheme's prefix to the identifier if necessary
  # For example:
  #   value   '0000-0000-0000-0001'
  #   becomes 'https://orcid.org/0000-0000-0000-0001'
  def value=(val)
    if identifier_scheme.present? &&
       identifier_scheme.identifier_prefix.present? &&
       !val.to_s.strip.blank? &&
       !val.to_s.starts_with?(identifier_scheme.identifier_prefix)

      base = identifier_scheme.identifier_prefix
      base += "/" unless base.ends_with?("/")
      super("#{base}#{val}")
    else
      super(val)
    end
  end

  private

  # ==============
  # = VALIDATION =
  # ==============

  # Simple check used by :validate methods above
  def has_scheme?
    self.identifier_scheme.present?
  end

  # Verify the uniqueness of :value across :identifiable
  def value_uniqueness_without_scheme
    # if scheme is nil, then just unique for identifiable
    if Identifier.where(identifiable: self.identifiable, value: self.value).any?
      errors.add(:value, _("must be unique"))
    end
  end

  # Ensure that the identifiable only has one identifier for the scheme
  def value_uniqueness_with_scheme
    if Identifier.where(identifier_scheme: self.identifier_scheme,
                        identifiable: self.identifiable).any?
      errors.add(:identifier_scheme, _("already assigned a value"))
    end
  end

end
