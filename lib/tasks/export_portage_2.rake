namespace :export do
    desc "Export guidances groups from 3.0.2 database" 
    task :export_portage_2 => :environment do   
        GuidanceGroup.all.each do |guidance_group| 
            excluded_keys =['created_at','updated_at'] 
            serialized = guidance_group.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
            puts "GuidanceGroup.create(#{serialized})"
      end 
    end
    desc "Export themes from 3.0.2 database" 
    task :export_portage_2 => :environment do
        Theme.all.each do |theme| 
            excluded_keys = ['created_at','updated_at'] 
            serialized = theme.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
            puts "Theme.create(#{serialized})"
        end
    end
end