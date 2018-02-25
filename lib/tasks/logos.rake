namespace :logos do
  desc "Resize all of the logos based on the settings in `models/org.rb`"
  task resize_all: :environment do
    Org.all.each do |org|
      if org.logo.present?
        img = org.logo
        org.logo = img
        org.save!
      end
    end
  end
  
  desc "Migrate old DMPTool production logos"
  task migrate: :environment do
    Org.all.each do |org|
      path = File.expand_path("../prod_logos/logo/#{org.id}/")
      if Dir.exist?(path) && !org.logo.present?
        logo = Dir.entries(path).last
        org.logo = Dragonfly.app.fetch_file("#{path}/#{logo}")
        org.save!
        puts "    uploaded logo for #{org.name}: #{logo}"
      else
        puts "    NO LOGO FOR: #{org.name}"
      end
      puts ""
    end
  end
end