# frozen_string_literal: true

require 'text'

module OrgSelection
  # This class provides a search mechanism for Orgs that looks at records in the
  # the database along with any available external APIs
  class OrgToHashService
    class << self
      # Convert an Identifiable Model over to hash results like:
      # An Org with id = 123, name = "Foo (foo.org)",
      #             identifier (ROR) = "http://example.org/123"
      # becomes:
      # {
      #   id: "123",
      #   ror: "http://ror.org/123",
      #   name: "Foo (foo.org)",
      #   sort_name: "Foo"
      # }
      def to_hash(org:)
        return {} if org.blank?

        out = {
          id: org.id,
          name: org.name,
          sort_name: OrgSelection::SearchService.name_without_alias(name: org.name)
        }
        # tack on any identifiers
        org.identifiers.each do |id|
          next if id.identifier_scheme.blank?

          out[:"#{id.identifier_scheme.name.downcase}"] = id.value
        end
        out
      end
    end
  end
end
