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
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def merge_commit
      @org = Org.find(params[:id])
      authorize @org

      @target_org = Org.find_by(id: merge_params[:target_org])
      associations = JSON.parse(merge_params[:mergeable_associations])
      attributes = JSON.parse(merge_params[:mergeable_attributes])

      if @target_org.present? && (associations.present? || attributes.present?)
        Org.transaction do
          merge_records(org: @org, target_org: @target_org, attributes: attributes,
                        associations: associations)

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
        end
      else
        msg = _("Unable to merge the two Orgs at this time.")
        redirect_to admin_edit_org_path(@org), alert: msg
      end
    rescue JSON::ParserError
      msg = _("Unable to determine what records need to be merged.")
      redirect_to admin_edit_org_path(@org), alert: msg
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
      params.require(:org).permit(:org_name, :org_sources, :org_crosswalk, :id, :target_org,
                                  :mergeable_associations, :mergeable_attributes)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
    def merge_records(org:, target_org:, attributes:, associations:)
      target_org.update(attributes) if attributes.any?

      # Reassociate any Plan-GuidanceGroup connections
      # Move the guidance to the target_org's guidance_group.
      new_gg = target_org.guidance_groups.first
      unless new_gg.present?
        new_gg = GuidanceGroup.create(org: target_org, name: target_org.abbreviation)
      end

      org.guidance_groups.each do |old_gg|
        old_gg.plans.each do |plan|
          plan.guidance_groups << new_gg
          plan.save
        end
        old_gg.plans.delete_all
      end

      # Process the other associations
      associations = associations.with_indifferent_access
      associations.each_key do |category|
        next unless associations[category].any?

        case category
        when "funded_plans"
          associations[category].each do |plan|
            plan = Plan.find_by(id: plan["id"])
            next unless plan.present?

            plan.update(funder_id: target_org.id)
          end
        when "guidances"
          associations[category].each do |guidance|
            guidance = Guidance.find_by(id: guidance["id"])
            next unless guidance.present?

            guidance.update(guidance_group: new_gg)
          end
        when "identifiers"
          # Update the identifiers' :identifiable_id to the target_org
          associations[category].each do |identifier|
            id = Identifier.find(identifier["id"].to_i)
            next unless id.present?

            id.update(identifiable_id: target_org.id)
          end
        when "token_permission_types"
          associations[category].each do |item|
            target_org.token_permission_types << TokenPermissionType.find_by(id: item["id"])
          end
          target_org.save
        else
          # Otherwise update the items' :org_id to the target_org
          clazz_name = category.singularize.split("_").map(&:capitalize).join("")
          clazz = clazz_name.constantize
          next unless clazz.present?

          associations[category].each do |item|
            obj = clazz.find_by(id: item["id"].to_i)
            next unless obj.present?

            obj.update(org_id: target_org.id)
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength

  end

end
