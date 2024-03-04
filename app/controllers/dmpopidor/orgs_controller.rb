# frozen_string_literal: true

module Dmpopidor
  # Customized code for OrgsController
  module OrgsController
    # Returns a list of active orgs in json
    # Removes current user's org from the list
    # rubocop:disable Metrics/AbcSize
    def list
      orgs_with_context = ::Org.joins(:templates).managed
                               .where(
                                 active: true,
                                 templates: { 
                                    published: true,
                                    archived: false,
                                    context: params[:context],
                                    locale: params[:locale]  
                                  }
                               )
      @orgs = if params[:type] == 'org'
                (orgs_with_context.organisation + orgs_with_context.institution + orgs_with_context.default_orgs)
              else
                [orgs_with_context.funder]
              end
      @orgs = @orgs.flatten.uniq.sort_by(&:name)
      authorize ::Org.new, :list?
      render json: @orgs.as_json(only: %i[id name])
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGE: ADDED BANNER TEXT and ACTIVE
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def admin_update
      attrs = org_params
      @org = ::Org.find(params[:id])
      authorize @org
      # If a new logo was supplied then use it, otherwise retain the existing one
      attrs[:logo] = attrs[:logo].present? ? attrs[:logo] : @org.logo
      # Remove the logo if the user checked the box
      attrs[:logo] = nil if attrs[:remove_logo] == '1'

      tab = (attrs[:feedback_enabled].present? ? 'feedback' : 'profile')
      @org.links = ActiveSupport::JSON.decode(params[:org_links]) if params[:org_links].present?

      @org.banner_text = attrs[:banner_text] if attrs[:banner_text]

      # Only allow super admins to change the org types and shib info
      if current_user.can_super_admin?
        identifiers = []
        attrs[:managed] = attrs[:managed] == '1'

        # Handle Shibboleth identifier if that is enabled
        if Rails.configuration.x.shibboleth.use_filtered_discovery_service
          shib = ::IdentifierScheme.by_name('shibboleth').first

          if shib.present? && attrs[:identifiers_attributes].present?
            key = attrs[:identifiers_attributes].keys.first
            entity_id = attrs[:identifiers_attributes][:"#{key}"][:value]
            # rubocop:disable Metrics/BlockNesting
            if entity_id.present?
              identifier = ::Identifier.find_or_initialize_by(
                identifiable: @org, identifier_scheme: shib, value: entity_id
              )
              @org = process_identifier_change(org: @org, identifier: identifier)
            else
              # The user blanked out the entityID so delete the record
              @org.identifier_for_scheme(scheme: shib)&.destroy
            end
            # rubocop:enable Metrics/BlockNesting
          end
          attrs.delete(:identifiers_attributes)
        end

        # See if the user selected a new Org via the Org Lookup and
        # convert it into an Org
        lookup = org_from_params(params_in: attrs)
        ids = identifiers_from_params(params_in: attrs)
        identifiers += ids.select { |id| id.value.present? }
      end

      # Remove the extraneous Org Selector hidden fields
      attrs = remove_org_selection_params(params_in: attrs)

      if @org.update(attrs)
        # Save any identifiers that were found
        if current_user.can_super_admin? && lookup.present?
          # Loop through the identifiers and then replace the existing
          # identifier and save the new one
          identifiers.each do |id|
            @org = process_identifier_change(org: @org, identifier: id)
          end
          @org.save
        end

        # if active is false, unpublish all published tempaltes, guidances
        unless @org.active
          @org.published_templates.update_all(published: false)
          @org.guidance_groups.update_all(published: false)
          @org.update(feedback_enabled: false)
        end

        redirect_to "#{admin_edit_org_path(@org)}##{tab}",
                    notice: success_message(@org, _('saved'))
      else
        failure = failure_message(@org, _('save')) if failure.blank?
        redirect_to "#{admin_edit_org_path(@org)}##{tab}", alert: failure
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
