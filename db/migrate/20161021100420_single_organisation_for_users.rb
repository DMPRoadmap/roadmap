class SingleOrganisationForUsers < ActiveRecord::Migration

  def up
    unless Rails.env.test?
      if table_exists?('users')
        User.class_eval do
          belongs_to :organisation,
                     :class_name => "Organisation",
                     :foreign_key => "organisation_id"
        end

        User.includes(:user_org_roles, :roles).all.each do | user |
          # NOTE: we'll grab the first organisation (if present), so if there are more, these will be lost!
          user.organisation_id = user.user_org_roles.first.organisation_id unless user.user_org_roles.empty?
          user.save!
        end
      end
    end
    
    drop_table :user_org_roles if table_exists? :user_org_roles
  end
end
