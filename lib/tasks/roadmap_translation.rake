# frozen_string_literal: true

namespace :roadmap_translation do
  desc 'Export Theme title values from the database and write html.erb file for upload to translation.io'
  task export_theme_values: :environment do
    file_path = Rails.root.join('app/views/translation_io_exports/_themes.html.erb')

    File.open(file_path, 'w') do |file|
      file.puts '<%='
      Theme.all.each do |theme|
        file.puts "_('#{theme.title}')"
      end
      file.puts '%>'
    end
  end
end
