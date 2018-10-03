module MailerHelper

  def tool_name
    @tool_name ||= Branding.fetch(:application, :name)
  end

  def helpdesk_email
    @helpdesk_email ||= Branding.fetch(:organisation, :helpdesk_email)
  end

  def contact_us_url
    @contact_us_url ||= Branding.fetch(:organisation, :contact_us_url)
  end

  def help_url
    @help_url ||= Branding.fetch(:organisation, :url)
  end

  def allow_change_prefs
    true
  end

end