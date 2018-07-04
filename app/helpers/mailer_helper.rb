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
end