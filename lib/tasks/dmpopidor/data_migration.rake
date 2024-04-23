# frozen_string_literal: true

namespace :data_migration do
  desc 'Cleaning data'
  task V4_0_3: :environment do
    p 'Upgrading to DMP OPIDoR v4.0.3'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:documentationquality_documentationsoftware_to_string_array'].execute
    Rake::Task['data_migration:clean_empty_metadatastandard'].execute
    Rake::Task['data_migration:clean_empty_host'].execute
    p '------------------------------------------------------------------------'
    p 'Upgrade complete'
  end
    desc 'Migrate DocumentationQuality.documentationSoftware to string array'
    task documentationquality_documentationsoftware_to_string_array: :environment do
        p 'Migrating DocumentationQuality.documentationSoftware  to string array'
        p '------------------------------------------------------------------------'
        Fragment::DocumentationQuality.all.each do |dq|
            documentation_software = dq.data['documentationSoftware']
            updated_data = dq.data.clone
            
            next if documentation_software.is_a?(Array) || !dq.data.key?('documentationSoftware')

            updated_data['documentationSoftware'] = if documentation_software.nil?
                                                      []
                                                    else
                                                      [documentation_software]
                                                    end
            dq.update_column(:data, updated_data)
        end
        p '------------------------------------------------------------------------'
        p 'Done'
    end
    desc 'Clean empty metadataStandard in Host'
    task clean_empty_metadatastandard: :environment do
      p 'Cleaning empty metadataStandard in Host'
      p '------------------------------------------------------------------------'
      Fragment::Host.all.each do |h|
        updated_data = h.data.clone
        metadata_standard_id = h.data.dig("metadataStandard", "dbid")
        next if metadata_standard_id.nil?

        metadata_standard = MadmpFragment.find(metadata_standard_id)
        metadata_standard_name = nil
        if metadata_standard.data.empty?
          metadata_standard.destroy
          updated_data.delete("metadataStandard")
        else
          metadata_standard.destroy
          updated_data.merge('metadataStandard' =>  metadata_standard.data['name'])
        end

        h.update_column(:data, updated_data)
      end
      p '------------------------------------------------------------------------'
      p 'Done'
    end

    desc 'Clean empty hosts'
    task clean_empty_host: :environment do
      p 'Cleaning empty hosts'
      p '------------------------------------------------------------------------'
      Fragment::Host.all.each do |h|
        if h.data.empty?
          h.destroy
        end
      end
      p '------------------------------------------------------------------------'
      p 'Done'
    end
end
