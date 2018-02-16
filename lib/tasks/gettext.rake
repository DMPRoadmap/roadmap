namespace :gettext do
  def files_to_translate
    Dir.glob("{app,config,locale}/**/*.{rb,erb,md,haml,slim,rhtml}")
  end
  
  desc 'Add the specified language to the database'
  task :add_language_to_database, [:code, :name, :is_default] => [:environment] do |t, args|
    if args[:code].present? && args[:name].present?
      Language.create!(abbreviation: args[:code], description: '', name: args[:name], default_language: (args[:is_default] == 1))
    end
  end
end