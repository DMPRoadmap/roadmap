namespace :export do
    desc "Export templates from 3.0.2 database" 
    task :export_to_seeds => :environment do
      Template.all.each do |template| 
        excluded_keys = ['created_at', 'updated_at', 'id'] 
        serialized = template.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
        puts "Template.create(#{serialized})"
      end 
    end
  end