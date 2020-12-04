# frozen_string_literal: true

module SuperAdmin

  class OrgsController < ApplicationController

    include OrgSelectable

    after_action :verify_authorized

    # GET /super_admin/orgs
    def index
      authorize Org
      render "index", locals: {
        orgs: Org.with_template_and_user_counts.page(1)
      }
    end

    # GET /super_admin/orgs/new
    def new
      @org = Org.new(managed: true)
      authorize @org
      @org.links = { "org": [] }
    end

    # POST /super_admin/orgs
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create
      authorize Org
      attrs = org_params

      # See if the user selected a new Org via the Org Lookup and
      # convert it into an Org
      org = org_from_params(params_in: attrs)

      # Remove the extraneous Org Selector hidden fields
      attrs = remove_org_selection_params(params_in: attrs)

      # In the event that the params would create an invalid user, the
      # org selectable returns nil because Org.new(params) fails
      org = Org.new unless org.present?

      org.language = Language.default
      org.managed = org_params[:managed] == "1"
      org.logo = params[:logo] if params[:logo]
      org.links = if params[:org_links].present?
                    JSON.parse(params[:org_links])
                  else
                    { org: [] }
                  end

      begin
        # TODO: The org_types here are working but would be better served as
        #       strong params. Consider converting over to follow the pattern
        #       for handling Roles in the ContributorsController. This will allow
        #       the use of all org_types instead of just these 3 hard-coded ones
        org.funder = params[:funder].present?
        org.institution = params[:institution].present?
        org.organisation = params[:organisation].present?

        if org.update(attrs)
          msg = success_message(org, _("created"))
          redirect_to admin_edit_org_path(org.id), notice: msg
        else
          flash.now[:alert] = failure_message(org, _("create"))
          @org = org
          @org.links = { "org": [] } unless org.links.present?
          render "super_admin/orgs/new"
        end
      rescue Dragonfly::Job::Fetch::NotFound
        failure = _("There seems to be a problem with your logo. Please upload it again.")
        redirect_to admin_edit_org_path(org), alert: failure
        render "orgs/admin_edit", locals: {
          org: org,
          languages: Language.all.order("name"),
          method: "POST",
          url: super_admin_orgs_path
        }
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # DELETE /super_admin/orgs/:id
    def destroy
      org = Org.includes(:users, :templates, :guidance_groups).find(params[:id])
      authorize org

      # Only allow the delete if the org has no dependencies
      return if !org.users.empty? || !org.templates.empty?

      org.guidance_groups.delete_all

      if org.destroy!
        msg = success_message(org, _("removed"))
        redirect_to super_admin_orgs_path, notice: msg
      else
        failure = failure_message(org, _("remove"))
        redirect_to super_admin_orgs_path, alert: failure
      end
    end

    # POST /super_admin/:id/merge_analyze
    def merge_analyze
      @org = Org.includes(:templates, :tracker, :annotations,
                          :departments, :token_permission_types, :funded_plans,
                          identifiers: [:identifier_scheme],
                          guidance_groups: [guidances: [:themes]],
                          users: [identifiers: [:identifier_scheme]])
                .find(params[:id])
      authorize @org

      lookup = OrgSelection::HashToOrgService.to_org(
        hash: JSON.parse(merge_params[:id]), allow_create: false
      )
      @target_org = Org.includes(:templates, :tracker, :annotations,
                                 :departments, :token_permission_types, :funded_plans,
                                 identifiers: [:identifier_scheme],
                                 guidance_groups: [guidances: [:themes]],
                                 users: [identifiers: [:identifier_scheme]])
                       .find(lookup.id)
    end

    # POST /super_admin/:id/merge_commit
    # rubocop:disable Metrics/AbcSize
    def merge_commit
      @org = Org.find(params[:id])
      authorize @org

      @target_org = Org.find(merge_params[:target_org])
      mergeables = JSON.parse(merge_params[:mergeables])

      if @target_org.present? && mergeables.present?
        merge_records(org: @org, target_org: @target_org, mergeables: mergeables)

        # Remove all of the Org's guidance_groups the guidances were moved above
        @org.guidance_groups.delete_all
        # Remove all of the remaining identifiers and token_permission_types
        # that were not merged
        @org.identifiers.delete_all
        @org.token_permission_types.delete_all

        if @org.destroy
          msg = "Successfully merged '#{@org.name}' into '#{@target_org.name}'"
          redirect_to super_admin_orgs_path, notice: msg
        else
          # rubocop:disable Layout/LineLength
          msg = _("Partial merge complete. Unable to delete '#{@org.name}'. Revisit the 'Merge' tab to see what records did not get merged.")
          # rubocop:enable Layout/LineLength
          redirect_to admin_edit_org_path(@org), alert: msg
        end
      else
        msg = _("Unable to merge the two Orgs at this time.")
        redirect_to admin_edit_org_path(@org), alert: msg
      end
    rescue JSON::ParserError
      msg = _("Unable to determine what records need to be merged.")
      redirect_to admin_edit_org_path(@org), alert: msg
    end
    # rubocop:enable Metrics/AbcSize

    private

    def org_params
      params.require(:org).permit(:name, :abbreviation, :logo, :managed,
                                  :contact_email, :contact_name,
                                  :remove_logo, :feedback_enabled,
                                  :feedback_email_subject,
                                  :feedback_email_msg,
                                  :org_id, :org_name, :org_crosswalk)
    end

    def merge_params
      params.require(:org).permit(:org_name, :org_sources, :org_crosswalk, :id,
                                  :target_org, :mergeables)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def merge_records(org:, target_org:, mergeables:)
      mergeables.each_key do |category|
        next unless mergeables[category].any?

        case category
        when "guidances"
          # Move the guidance to the target_org's guidance_group.
          gg = target_org.guidance_groups.first
          gg = GuidanceGroup.new(org: org, name: org.abbreviation) unless gg.present?

          mergeables[category].each do |guidance|
            guidance = Guidance.find(guidance["id"])
            next unless guidance.present?

            guidance.update(guidance_group: gg)
          end
        when "identifier"
          # Update the identifiers' :identifiable_id to the target_org
          mergeables[category].each do |identifier|
            id = Identifier.find(identifier["id"])
            next unless id.present?

            id.update(identifiable_id: target_org.id)
          end
        else
          # Otherwise update the items' :org_id to the target_org
          clazz = category.singularize.capitalize.constantize
          next unless clazz.present?

          mergeables[category].each do |item|
            obj = clazz.find_by(id: item["id"])
            next unless obj.present?

            obj.update(org_id: target_org.id)
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  end

end
