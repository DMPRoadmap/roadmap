class ReplacingOrganisationTypesWithBitflags < ActiveRecord::Migration
  # requires flag_shih_tzu for bitfields
  def change
    # add org_type field to orgs
    change_table :orgs do |t|
      t.integer :org_type, null: false, default: 0      # flag_shih_tzu-managed bitfield
      # Effective booleans which will be stored on the flags column:
      # t.boolean :Organisation
      # t.boolean :Funder
      # t.boolean :Institution
      # t.boolean :Reaserch_Institution
      # t.boolean :School
      # t.boolean :Project
    end
    
    if table_exists?('orgs')
      # migrate old org_type data to bitfield
      Org.includes(:organisation_type).all.each do |org|
        unless org.organisation_type.nil?
          case org.organisation_type.name
            when "Organisation"
              org.organisation = true
            when "Funder"
              org.funder = true
            when "Project"
              org.project = true
            when "School"
              org.school = true
            when "Institution"
              org.institution = true
            when "Research Institute"
              org.research_institute = true
          end
          org.save!
        end
      end
    end
    
    # remove organisation_type_id field from orgs
    remove_column :orgs, :organisation_type_id
    # remove organisation_type table
    drop_table :organisation_types
  end
end
