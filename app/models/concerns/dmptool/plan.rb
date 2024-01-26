# frozen_string_literal: true

module Dmptool
  # DMPTool extensions to the base Plan model
  module Plan
    extend ActiveSupport::Concern

    included do
      # Method required by the DMPTool::Registerable concern that checks to see if the Plan has all of the
      # content required to register a DMP ID
      def registerable?
        contact = primary_contact
        return false if contact.nil?

        orcid = contact.identifier_for_scheme(scheme: 'orcid').present?
        token = ExternalApiAccessToken.for_user_and_service(user: contact, service: 'orcid')
        visibility_allowed? && orcid.present? && (token.present? || Rails.env.development?) && funder.present?
      end

      # Retrieve the Primary contact for the DMP ID
      def primary_contact
        contact = ::Role.includes(user: [identifiers: [:identifier_scheme]]).where(access: 15, plan_id: id).first&.user

        # Sometimes the owner can be nil if the user was deleted/anonymized and in dev/stage, after replacing the DB
        # with a copy of production, the owner of the plan can not be found OR has been set to a generic
        # 'dmptool.researcher@gmail.com' account because it is out of sync with the DMPHub.
        #
        # In these scenarios, replace the :contact with the first PI in :contributor that has an ORCID
        if contact.nil? || contact.email == 'dmptool.researcher@gmail.com' ||
           contact.identifier_for_scheme(scheme: 'orcid').nil?

          contact = contributors.select { |c| c.investigation? && c.identifier_for_scheme(scheme: 'orcid').present? }.first
       end

       contact
      end
    end

    class_methods do
      # rubocop:disable Metrics/AbcSize
      def faceted_search(facets: {}, sort_by: 'plans.featured desc, plans.created_at desc')
        return order(sort_by) unless facets.is_a?(ActionController::Parameters)

        funder_ids = facets.fetch(:funder_ids, [])
        org_ids = facets.fetch(:institution_ids, [])
        language_ids = facets.fetch(:language_ids, [])
        subject_ids = facets.fetch(:subject_ids, [])

        clause = []
        clause << 'plans.funder_id IN (:funder_ids)' if funder_ids.any?
        clause << 'plans.org_id IN (:org_ids)' if org_ids.any?
        clause << 'plans.language_id IN (:language_ids)' if language_ids.any?
        clause << 'plans.research_domain_id IN (:subject_ids)' if subject_ids.any?
        return order(sort_by) if clause.blank?

        where(clause.join(' AND '), funder_ids: funder_ids, org_ids: org_ids, language_ids: language_ids,
                                    subject_ids: subject_ids)
          .order(sort_by)
      end
      # rubocop:enable Metrics/AbcSize

       # Support for filtering and search
      def react_search(user:, params: {})
        return [] unless user.is_a?(User) && !user.org_id.nil?

        recs = where('dmp_id IS NOT NULL AND org_id = ?', user&.org_id)

        title = params.fetch(:title, '').to_s.strip
        funder = params.fetch(:funder, '').to_s.strip
        grant = params.fetch(:grant_id, '').to_s.strip
        visibility = params.fetch(:visibility, '').to_s.strip
        dmp_id = params.fetch(:dmp_id, '').to_s.strip

        funder_ids = funder.present? ? Org.where('name LIKE ?',  "%#{funder}%").pluck(:id) : []
        grant_ids = grant.present? ? Identifier.where('value LIKE ?', "%#{grant_id}%").pluck(:id) : []

        clause = []
        clause << '(LOWER(title) LIKE :title OR LOWER(description) LIKE :title)' unless title.blank?
        clause << '(funder_id IN :funder_ids)' unless funder_ids.empty?
        clause << '(grant_id IN :grant_ids)' unless grant_ids.empty?
        clause << visibility == 'public' ? '(visibility = 1)' : '(visibility != 1)' unless visibility.blank?
        clause << "dmp_id LIKE :dmp_id" unless dmp_id.blank?

pp clause

        return recs unless clause.any?

        recs = recs.where(clause.join(' AND '), title: "%#{title.downcase}%", funder_ids: funder_ids,
                                                grant_ids: grant_ids, dmp_id: "%#{dmp_id}",
                                                visibility: visibility.downcase)
        recs
      end
    end
  end
end
