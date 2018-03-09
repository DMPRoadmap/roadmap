module PermsHelper
  # Returns a hash whose keys are the names associated to Perms and values are the text to be displayed to the end user
  def name_and_text
    {
      :add_organisations => _('Add organisations'),
      :change_org_affiliation => _('Change affiliation'),
      :grant_permissions => _('Manage user privileges'),
      :modify_templates => _('Manage templates'),
      :modify_guidance => _('Manage guidance'),
      :use_api => _('API rights'),
      :change_org_details => _('Manage organisation details'),
      :grant_api_to_orgs => _('Grant API to organisations')
    }
  end
end