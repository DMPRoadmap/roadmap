namespace :assets do
  desc 'Copy Bootstrap glyphicons and TinyMCE skins to the public directory'
  task :copy do
    # Bootstrap and TinyMCE expect their files to live in a specific place, so copy them over
    puts 'Copying Bootstrap glyphicons to the public directory ...'
    source_dir = Dir.glob(Rails.root.join('node_modules', 'bootstrap', 'fonts', 'glyphicons-halflings-regular.*'))
    destination_dir = Rails.root.join('public', 'fonts', 'bootstrap')
    FileUtils.mkdir_p(destination_dir)
    FileUtils.cp_r(source_dir, destination_dir)

    puts 'Copying TinyMCE skins to the public directory ...'
    source_dir = Dir.glob(Rails.root.join('node_modules', 'tinymce', 'skins', 'ui', 'oxide'))
    destination_dir = Rails.root.join('public', 'tinymce', 'skins')
    FileUtils.mkdir_p(destination_dir)
    FileUtils.cp_r(source_dir, destination_dir)
  end

  # Run the copy task before precompiling assets
  task precompile: :copy
end
