# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController

  include OrgSelectable

  # Creates the selected Org if necessary and then attaches the invited user
  # to the Org after Devise does its thing
  prepend_after_action :handle_org, only: [:update]
  prepend_before_action :fix_org_params, only: [:update]

  protected

  def fix_org_params
    hash = org_hash_from_params(params_in: params[:user])
    org = OrgSelection::HashToOrgService.to_org(hash: hash,
                                                allow_create: false)
    params[:user][:org_id] = org&.id
  end

  # Override require_no_authentication method defined at DeviseController
  # (parent of Devise::InvitationsController) The following filter gets
  # executed any time GET /users/invitation/accept?invitation_token=valid_token
  # is requested. It replaces the default error message from devise
  # (e.g. You are already signed in.) if the user is signed in already while
  # trying to access to that URL
  def require_no_authentication
    super
    return unless flash[:alert].present?

    flash[:alert] = nil
    # rubocop:disable Layout/LineLength
    flash[:notice] = _("You are already signed in as another user. Please log out to activate your invitation.")
    # rubocop:enable Layout/LineLength
  end

  # Handle the user's Org selection
  def handle_org
    attrs = update_resource_params

    return unless attrs[:org_id].present?

    # See if the user selected a new Org via the Org Lookup and
    # convert it into an Org
    lookup = org_from_params(params_in: attrs)
    return nil unless lookup.present?

    # If this is a new Org we need to save it first before attaching
    # it to the user
    if lookup.new_record?
      lookup.save
      identifiers_from_params(params_in: attrs).each do |identifier|
        next unless identifier.value.present?

        identifier.identifiable = lookup
        identifier.save
      end
      lookup.reload
    end

    resource.update(org_id: lookup.id)
  end

end
