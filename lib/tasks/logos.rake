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

  desc "Attempt to reattach disassociated DB references to logos"
  task repair_paths: :environment do
    dragonfly_path = Rails.root.join("public", "system", "dragonfly")
    if Dir.exist?(dragonfly_path)
      logos = find_logos(dragonfly_path)

      logos.keys.each do |logo|
        org = Org.find_by(logo_name: logo)
        if org.present?
          path = logos[logo].gsub(dragonfly_path)
          "Found logo for #{org.name} - updating path from #{org.logo_uid} to #{path}"
          org.update(logo_uid: path)
        end
      end
    end
  end

  def find_logos(path)
    entries = {}
    if Dir.exist?(path)
      Dir.foreach(path) do |entry|
        unless entry.start_with?(".")
          if File.ftype(path.join(entry)) == "directory"
            entries = entries.merge(find_logos(path.join(entry)))
          else
            entries["#{entry}"] = path.join(entry).to_s
          end
        end
      end
    end
    entries
  end

end
