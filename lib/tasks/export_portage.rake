namespace :export_production_data do
    desc "Build all stats"
    # The procedure can be adjusted depending on whether the task will be run in a different server first
    task build_sandbox_data: :environment do
        ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym) 
        # if we are going to do: rake export_production_data:build_sandbox_data RAILS_ENV=development, the line above can be eliminated. It is just to make sure we start from an env other than sandbox
        puts 'Make sure this task in running under production database instead of sandbox database.'
        puts 'seed_0 is manually generated. Skip.'
        puts 'generating seed_1.rb...'
        Rake::Task['export_production_data:seed_1_export'].execute
        puts 'generating seed_2.rb...'
        Rake::Task['export_production_data:seed_2_export'].execute
        puts 'generating seed_3.rb...'
        Rake::Task['export_production_data:seed_3_export'].execute
        puts 'seed_4 is manually generated. Skip.'
        puts 'seed_5 is manually generated. Skip.'
        puts 'seed_6 is manually generated. Now switch to sandbox db environment and seed'
        puts 'Now copy seeds.rb and all files in seeds folder to sandbox server, then run bundle exec rake db:reset (or db:setup for the first time)' # we could make this run separately & manually also. this line is to reset/setup the database under sandbox environment
    end

    #####################################################
    ## In order to preserve the sequence of the seed file 
    ## Following tasks needs to be run in sequence
    #####################################################

    # seed_1: org & question format must be created before templates and template-related components
    desc "Export org and question format from 3.0.2 database to seeds_1.rb" 
    task :seed_1_export => :environment do
        file_name = 'db/seeds/seeds_1.rb'
        File.delete(file_name) if File.exist?(file_name)
        Faker::Config.random = Random.new(Org.count)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] 
            created = 6.years.ago
            Org.all.each do |org|
                if org.id == ENV['ENGLISH_ORG_ID'].to_i
                    org.name = "Test Organization"
                    org.abbreviation = "IEO"
                    org.language_id = 1 # English Default
                    org.logo_name = "Test_Organization.png"
                elsif org.id == ENV['FRENCH_ORG_ID'].to_i
                    org.name = "Organisation de test"
                    org.abbreviation = "OEO"
                    org.language_id = 2 # French Default
                    org.logo_name = "Organisation_de_test.png"
                elsif org.id.to_i != ENV['FUNDER_ORG_ID'].to_i # Only Portage keep its original name and all other information
                    org.name = Faker::University.name
                    org.abbreviation = org.name + "_abbreviation"
                end
                org.created_at = created # hard-code org creation date because it must be created before all templates/plans created
                org.target_url = Org.column_defaults["target_url"]
                org.logo_uid = Org.column_defaults["logo_uid"]
                org.logo_name = Org.column_defaults["logo_name"]
                org.banner_name = Org.column_defaults["banner_name"]
                org.contact_email = Faker::Internet.email
                org.links = Org.column_defaults["links"]
                org.feedback_msg = Org.column_defaults["feedback_msg"]
                org.contact_name = Faker::Name.name
                serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Org.create!(#{serialized})"
            end
            QuestionFormat.all.each do |question_formats| 
                excluded_keys = ['created_at','updated_at'] 
                serialized = question_formats.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "QuestionFormat.create(#{serialized})"
            end
        end
    end

    # seed2: guidance group and theme must be created before guidance and questions (using theme)
    desc "Export guidance group and theme format from 3.0.2 database to seeds_2.rb" 
    task :seed_2_export => :environment do
        file_name = 'db/seeds/seeds_2.rb'
        File.delete(file_name) if File.exist?(file_name)
        excluded_keys =['created_at','updated_at'] 
        open(file_name, 'a') do |f|
            GuidanceGroup.all.each do |guidance_group| 
                serialized = guidance_group.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "GuidanceGroup!.create(#{serialized})"
            end 
            Theme.all.each do |theme| 
                serialized = theme.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Theme!.create(#{serialized})"
            end
        end
    end

    # seed3: guidance and template related components runs lastly
    desc "Export guidance and template_related content from 3.0.2 database to seeds_3.rb" 
    task :seed_3_export => :environment do
        file_name = 'db/seeds/seeds_3.rb'
        File.delete(file_name) if File.exist?(file_name)
        excluded_keys =['created_at','updated_at'] 
        open(file_name, 'a') do |f|
            GuidanceGroup.all.each do |guidance_group|
                guidances = Guidance.where(:guidance_group_id => guidance_group.id) 
                guidances.all.each do |guidance|
                    guidance.theme_ids = [Theme.all.sample.id]
                    serialized = guidance.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                    f.puts "Guidance.create(#{serialized})"
                end
            end
            Template.where('title LIKE ?', '%Portage%').where(:published => true).all.each do |template| # only use portage network template
                # since too many version of template could cause rake to crash on seeding process, just get the published version
                serialized = template.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Template!.create(#{serialized})"
                # create phases
                phases = Phase.where(:template_id => template.id) # retrieve template old id
                phases.all.each do |phase|
                    serialized = phase.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                    f.puts "Phase.create(#{serialized})"
                    # create sections
                    sections = Section.where(:phase_id => phase.id)
                    sections.all.each do |section|
                        serialized = section.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                        f.puts "Section.create(#{serialized})"
                        # create questions
                        questions = Question.where(:section_id => section.id)
                        questions.all.each do |question|
                            excluded_keys = ['created_at','updated_at'] 
                            serialized = question.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                            f.puts "Question.create(#{serialized})"
                            # create question options
                            question_options = QuestionOption.where(:question_id => question.id)
                            question_options.all.each do |question_option|
                                serialized = question_option.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                                f.puts "QuestionOption.create(#{serialized})"
                            end
                            # create annotations
                            annotations = Annotation.where(:question_id => question.id)
                            annotations.all.each do |annotation|
                                serialized = annotation.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                                f.puts "Annotation.create(#{serialized})"
                            end
                        end
                    end
                end
            end 
        end
    end
end