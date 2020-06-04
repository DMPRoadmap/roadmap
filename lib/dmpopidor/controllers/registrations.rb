module Dmpopidor
  module Controllers
    module Registrations

      # Excluded funder orgs from registrations
      def edit
        @user = current_user
        @prefs = @user.get_preferences(:email)
        @languages = Language.sorted_by_abbreviation
        @orgs = Org.where(active: true).where.not('org_type = 2').order("name")
        @other_organisations = Org.where(is_other: true).pluck(:id)
        @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
        @default_org = current_user.org
     
        if !@prefs
          flash[:alert] = "No default preferences found (should be in branding.yml)."
        end
      end
    end
  end
end