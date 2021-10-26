# frozen_string_literal: true

module Dmpopidor

  module Registrations

    # Excluded funder orgs from registrations
    def edit
      @user = current_user
      @prefs = @user.get_preferences(:email)
      @languages = Language.sorted_by_abbreviation
      @orgs = Org.where(active: true).where.not("org_type = 2").order("name")
      @other_organisations = Org.where(is_other: true).pluck(:id)
      @identifier_schemes = IdentifierScheme.for_users.order(:name)
      @default_org = current_user.org

      msg = "No default preferences found (should be in dmproadmap.rb initializer)."
      flash[:alert] = msg unless @prefs
    end

  end

end
