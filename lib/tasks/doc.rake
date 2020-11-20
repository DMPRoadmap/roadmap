namespace :tomdoc do
  desc "Removes the docs from the ./doc directory"
  task :clear  do
    FileUtils.rm_r(Rails.root.join("doc"))
  end

  desc "Builds documentation in the ./doc directory"
  task :app do
    puts "Please wait..."
    options = []
    # Parse documentation as Tomdoc (https://tomdoc.org)
    options << "--plugin tomdoc"
    # Specify which file to use for the main index (README)
    options << "--readme README.md"
    # Hides return types specified as 'void'.
    options << "--hide-void-return"
    # Add a custom title to the HTML docs
    options << "--title 'DMP Roadmap'"
    # Include protected methods
    options << "--protected"
    # Include private methods
    options << "--private"
    # Set methods with no Return value to 'void'
    options << "--default-return 'void'"
    system("yard doc #{options.join(" ")}")
  end

  desc "Builds documentation in the ./doc directory"
  task :open do
    `open doc/index.html`
  end
end

task tomdoc: ["tomdoc:clear", "tomdoc:app", "tomdoc:open"] do
end

# Clear Rails' default doc tasks first.
task("doc:app").clear.enhance(["tomdoc:app"])
