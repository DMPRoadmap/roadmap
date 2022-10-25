# frozen_string_literal: true

namespace :logos do
  desc 'Migrate logos to S3'
  task s3_migration: :environment do
    Org.where.not(logo_uid: nil).each do
      # Find the old logo path
      path = File.expand_path("../public/system/dragonfly/production/#{org.logo_uid}")
      next unless File.exist?(path)

      # If the old logo file exists resubmit it through the model so that it goes into S3
      org.update(logo: File.open(path))
      org.reload
      p "Migrated logo for #{org.abbreviation} from '#{path}' to '#{org.logo_uid}'"
    end
  end

  desc 'Resize all of the logos based on the settings in `models/org.rb`'
  task resize_all: :environment do
    Org.all.each do |org|
      next if org.logo.blank?

      img = org.logo
      org.logo = img
      org.save!
    end
  end

  desc 'Migrate old DMPTool production logos'
  task migrate: :environment do
    Org.all.each do |org|
      path = File.expand_path("../prod_logos/logo/#{org.id}/")
      if Dir.exist?(path) && org.logo.blank?
        logo = Dir.entries(path).last
        org.logo = Dragonfly.app.fetch_file("#{path}/#{logo}")
        org.save!
        puts "    uploaded logo for #{org.name}: #{logo}"
      else
        puts "    NO LOGO FOR: #{org.name}"
      end
      puts ''
    end
  end

  desc 'Attempt to reattach disassociated DB references to logos'
  task repair_paths: :environment do
    dragonfly_path = Rails.public_path.join('system', 'dragonfly')
    if Dir.exist?(dragonfly_path)
      logos = find_logos(dragonfly_path)

      logos.each_key do |logo|
        org = Org.find_by(logo_name: logo)
        next if org.blank?

        path = logos[logo].gsub(dragonfly_path)
        p "Found logo for #{org.name} - updating path from #{org.logo_uid} to #{path}"
        org.update(logo_uid: path)
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def find_logos(path)
    entries = {}
    if Dir.exist?(path)
      Dir.foreach(path) do |entry|
        unless entry.start_with?('.')
          if File.ftype(path.join(entry)) == 'directory'
            entries = entries.merge(find_logos(path.join(entry)))
          elsif ['.png', '.jpg', '.jpeg', '.tif', '.tiff', '.bmp'].include?(File.extname(entry))
            entries[entry.split('_').last.to_s] = path.join(entry).to_s
          end
        end
      end
    end
    entries
  end
  # rubocop:enable Metrics/AbcSize
end
