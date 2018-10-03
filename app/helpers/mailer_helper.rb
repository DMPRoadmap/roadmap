module MailerHelper
  include PermsHelper

  # Returns an unordered HTML list with the permissions associated to the user passed
  def privileges_list(user)
    if user.respond_to?(:perms) && user.perms.respond_to?(:each)
      names = name_and_text
      r= "<ul>"
      user.perms.each do |p|
        r+="<li>#{names[p.name.to_sym]}</li>" if names.has_key?(p.name.to_sym)
      end
      r+= "</ul>"
    end
  end

  def tool_name
    Branding.fetch(:application, :name)
  end

  def helpdesk_email
    Branding.fetch(:organisation, :helpdesk_email)
  end

  def contact_us_url
    Branding.fetch(:organisation, :contact_us_url)
  end

  def help_url
    Branding.fetch(:organisation, :url)
  end

  def allow_change_prefs
    true
  end

end