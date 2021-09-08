# frozen_string_literal: true

module SuperAdmin

  module Orgs

    class MergePresenter

      attr_accessor :from_org, :to_org, :from_org_name, :to_org_name,
                    :from_org_entries, :to_org_entries, :mergeable_entries,
                    :categories, :from_org_attributes, :to_org_attributes,
                    :mergeable_attributes

      def initialize(from_org:, to_org:)
        @from_org = from_org
        @to_org = to_org

        # Abbreviated Org names for display in tables
        @from_org_name = @from_org.name.split(" ")[0..2].join(" ")
        @to_org_name = @to_org.name.split(" ")[0..2].join(" ")

        # Association records
        @from_org_entries = prepare_org(org: @from_org)
        @to_org_entries = prepare_org(org: @to_org)
        @mergeable_entries = prepare_mergeables
        @categories = @from_org_entries.keys.sort { |a, b| a <=> b }

        # Specific Org columns
        @from_org_attributes = org_attributes(org: @from_org)
        @to_org_attributes = org_attributes(org: @to_org)
        @mergeable_attributes = mergeable_columns
      end

      private

      # rubocop:disable Metrics/AbcSize
      def prepare_org(org:)
        return {} unless org.present? && org.is_a?(Org)

        {
          annotations: org.annotations.sort { |a, b| a.text <=> b.text },
          departments: org.departments.sort { |a, b| a.name <=> b.name },
          funded_plans: org.funded_plans.sort { |a, b| a.title <=> b.title },
          guidances: org.guidance_groups.collect(&:guidances).flatten,
          identifiers: org.identifiers.sort { |a, b| a.value <=> b.value },
          # TODO: Org.plans is overridden and does not clearly identify Orgs that 'own'
          #       the plan (i.e. the one the user selected as the 'Research Org')
          #       Loading them directly here until issue #2724 is resolved
          plans: Plan.where(org: org).sort { |a, b| a.title <=> b.title },
          templates: org.templates.sort { |a, b| a.title <=> b.title },
          token_permission_types: org.token_permission_types.sort { |a, b| a.to_s <=> b.to_s },
          tracker: [org.tracker].compact,
          users: org.users.sort { |a, b| a.email <=> b.email }
        }
      end
      # rubocop:enable Metrics/AbcSize

      def prepare_mergeables
        return {} unless @from_org_entries.any? && @to_org_entries.any?

        {
          annotations: diff_from_and_to(category: :annotations),
          departments: diff_from_and_to(category: :departments),
          funded_plans: diff_from_and_to(category: :funded_plans),
          guidances: diff_from_and_to(category: :guidances),
          identifiers: diff_from_and_to(category: :identifiers),
          plans: diff_from_and_to(category: :plans),
          templates: diff_from_and_to(category: :templates),
          token_permission_types: diff_from_and_to(category: :token_permission_types),
          tracker: @to_org_entries[:tracker].any? ? [] : @from_org_entries[:tracker],
          users: diff_from_and_to(category: :users)
        }
      end

      # rubocop:disable Metrics/AbcSize
      def diff_from_and_to(category:)
        return [] unless category.present? && @from_org_entries.fetch(category, []).any?

        case category
        when :departments
          # Merge only the unique departments
          existing = @to_org_entries[category].map { |e| e.name.downcase }
          @from_org_entries[category].reject { |e| existing.include?(e.name.downcase) }
        when :identifiers
          # Merge identifiers with no identifier_scheme
          # Retain the to_org's identifiers for specific identifier_schemes
          schemes = @to_org_entries[category].collect(&:identifier_scheme)
          @from_org_entries[category].reject do |entry|
            entry.identifier_scheme.present? && schemes.include?(entry.identifier_scheme)
          end
        when :token_permission_types
          # Merge only the unique token_permission_types
          existing = @to_org_entries[category].map { |e| e.token_type.downcase }
          @from_org_entries[category].reject { |e| existing.include?(e.token_type.downcase) }
        when :users
          # Merge only the unique users
          existing = @to_org_entries[category].map { |e| e.email.downcase }
          @from_org_entries[category].reject { |e| existing.include?(e.email.downcase) }
        else
          @from_org_entries[category]
        end
      end
      # rubocop:enable Metrics/AbcSize

      def org_attributes(org:)
        return {} unless org.is_a?(Org)

        {
          contact_email: org.contact_email,
          contact_name: org.contact_name,
          feedback_msg: org.feedback_msg,
          feedback_enabled: org.feedback_enabled,
          managed: org.managed,
          links: org.links,
          logo_name: org.logo_name,
          logo_uid: org.logo_uid,
          target_url: org.target_url
        }
      end

      def mergeable_columns
        out = {}
        out[:target_url] = @from_org.target_url if mergeable_column?(column: :target_url)
        out[:managed] = @from_org.managed if mergeable_column?(column: :managed)
        out[:links] = @from_org.links if mergeable_column?(column: :links)

        if mergeable_column?(column: :logo)
          out[:logo_uid] = @from_org.logo_uid
          out[:logo_name] = @from_org.logo_name
        end
        if mergeable_column?(column: :contact_email)
          out[:contact_email] = @from_org.contact_email
          out[:contact_name] = @from_org.contact_name
        end
        if mergeable_column?(column: :feedback_enabled)
          out[:feedback_enabled] = @from_org.feedback_enabled
          out[:feedback_msg] = @from_org.feedback_msg
        end
        out
      end

      def mergeable_column?(column:)
        case column
        when :links
          (@to_org.links.nil? || @to_org.links.fetch("org", []).empty?) &&
            (@from_org.links.present? || @from_org.links.fetch("org", [].any?))
        when :managed
          !@to_org.managed? && @from_org.managed?
        when :feedback_enabled
          !@to_org.feedback_enabled? && @from_org.feedback_enabled?
        else
          @to_org.send(column).nil? &&
            @from_org.send(column).present? &&
            @to_org != @from_org
        end
      end

    end

  end

end
