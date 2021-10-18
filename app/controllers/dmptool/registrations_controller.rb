# frozen_string_literal: true

module Dmptool

  module RegistrationsController

    # POST /users (via UJS form_with)
    def create

pp resource_params.inspect

    end

    # PUT /users (via the edit profile page)
    def update

    end

    private

    def org_params
      params.require(:org_autocomplete).permit(:name, :crosswalk, :not_in_list,
                                               :user_entered_name)
    end

    def org_lookup

pp @resource.inspect

      ror = RegistryOrg.find_by(name: org_params[:name]) if org_params[:name].present?
      @resource.org_id = ror.to_org&.id if ror.present?
      return true if ror.present?

      # Just double check to make sure its not a known RegistryOrg!
      ror = RegistryOrg.find_by(name: org_params[:user_entered_name])
      return ror.to_org&.id if ror.present?

      # Its a new Org, so initialize it
      org = Org.initialize_from_org_autocomplete(name: org_params[:user_entered_name])
      return nil unless org.present? && org.valid?

      # Save the new Org if it's valid
      org.save
      org.id
    end

  end

end
