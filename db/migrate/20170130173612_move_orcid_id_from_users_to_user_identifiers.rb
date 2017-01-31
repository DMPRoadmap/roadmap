class MoveOrcidIdFromUsersToUserIdentifiers < ActiveRecord::Migration
  def change

    if table_exists?('users') && table_exists?('identifier_schemes')
      scheme = IdentifierScheme.find_by(name: 'orcid')
      
      unless scheme.nil?
        User.all.each do |u|
          unless u.orcid_id.nil?
            u.user_identifiers << UserIdentifier.new(identifier_scheme: scheme, identifier: u.orcid_id)
            u.save!
          end
        end
        
        remove_column :users, :orcid_id
      end
    end

  end
end
