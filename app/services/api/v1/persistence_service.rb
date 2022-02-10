# frozen_string_literal: true

module Api

  module V1

    # Service used to ensure the entire DMP stack is saved
    class PersistenceService

      class << self

        def safe_save(plan:)
          return nil unless plan.is_a?(Plan) && plan.valid?

          plan.contributors = deduplicate_contributors(contributors: plan.contributors)

          Plan.transaction do
            plan.funder = safe_save_org(org: plan.funder)
            plan.grant = safe_save_identifier(identifier: plan.grant)

            plan.save

            plan.identifiers.each do |id|
              id.identifiable = plan.reload
              safe_save_identifier(identifier: id)
            end
            plan.contributors.each do |contributor|
              contributor.plan = plan.reload
              safe_save_contributor(contributor: contributor)
            end

            plan.reload
          end
        end

        private

        def safe_save_identifier(identifier:)
          return nil unless identifier.is_a?(Identifier)

          Identifier.transaction do
            identifier.save if identifier.valid?
            return identifier unless identifier.new_record?
          end

          Identifier.where(identifier_scheme: identifier.identifier_scheme,
                           value: identifier.value,
                           identifiable: identifier.identifiable).first
        end

        def safe_save_org(org:)
          return nil unless org.is_a?(Org)

          Org.transaction do
            organization = Org.find_or_initialize_by(name: org.name)
            if organization.new_record?
              # Now that we know its a new record make sure its valid first
              return nil unless org.valid?

              organization.update(saveable_attributes(attrs: org.attributes))
              org.identifiers.each do |id|
                id.identifiable = organization.reload
                safe_save_identifier(identifier: id)
              end
            end
            organization.reload
          end
        end

        def safe_save_contributor(contributor:)
          return nil unless contributor.is_a?(Contributor) && contributor.valid?

          Contributor.transaction do
            contrib = Contributor.find_or_initialize_by(email: contributor.email)

            if contrib.new_record?
              contrib.update(saveable_attributes(attrs: contributor.attributes))
              contrib.update(org: safe_save_org(org: contributor.org)) if contributor.org.present?

              contributor.identifiers.each do |id|
                id.identifiable = contrib.reload
                safe_save_identifier(identifier: id)
              end
            end
            contrib.reload
          end
        end

        # Consolidate the contributors so that we don't end up trying to insert
        # duplicate records!
        def deduplicate_contributors(contributors:)
          out = []
          return out unless contributors.respond_to?(:any?) && contributors.any?

          contributors.each do |contributor|
            next unless contributor.is_a?(Contributor)

            # See if we've already processed this contributor
            existing = out.select { |c| c == contributor }.first
            out << contributor unless existing.present?
            next unless existing.present?

            existing.merge(contributor)
          end
          out.flatten.compact.uniq
        end

        def id_for(model, scheme)
          return nil unless model.respond_to?(:identifier_for_scheme) && scheme.present?

          model.identifier_for_scheme(scheme: scheme)
        end

        def saveable_attributes(attrs:)
          %w[id created_at updated_at].each { |key| attrs.delete(key) }
          attrs
        end

      end

    end

  end

end
