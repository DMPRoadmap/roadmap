namespace :export_production_data do
    desc "Generate seed files"
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
        puts 'generating seed_5.rb...'
        Rake::Task['export_production_data:seed_5_export'].execute
        puts 'seed_5 is manually generated. Skip.'
        puts 'Now switch to sandbox db environment and seed'
        puts 'Now copy seeds.rb and all files in seeds folder to sandbox server, then run bundle exec rake db:reset (or db:setup for the first time)' # we could make this run separately & manually also. this line is to reset/setup the database under sandbox environment
    end

    #####################################################
    ## In order to preserve the sequence of the seed file 
    ## Following tasks needs to be run in sequence
    #####################################################

    # seed_1: org & question format must be created before templates and template-related components
    desc "Export org and question format from 3.0.2 database to seeds_1.rb" 
    task :seed_1_export => :environment do
        file_name = 'db/seeds/sandbox/seeds_1.rb'
        File.delete(file_name) if File.exist?(file_name)
        Faker::Config.random = Random.new(Org.count)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] 
            created = 6.years.ago # hard-code org creation date because it must be created before all templates/plans created
            Org.all.each do |org|
                # feedback message must fit the default language
                if org.language_id == 2 || org.id == Rails.application.secrets.french_org_id.to_i
                    org.feedback_msg = '<p>Bonjour %{user_name}. </p><br><p> Votre plan "%{plan_name}" a été soumis pour commentaires d’un administrateur de votre organisation. <br>Si vous avez des questions concernant cette action, veuillez communiquer avec nous à %{organisation_email}.</p>'
                else
                    org.feedback_msg = '<p>Hello %{user_name}.</p><br><p>Your plan "%{plan_name}" has been submitted for feedback from an administrator at your organisation.<br>If you have questions pertaining to this action, please contact us at %{organisation_email}.</p>'
                end
                # Only FUNDER_ORG(Portage) keep its original information 
                if org.id.to_i != Rails.application.secrets.funder_org_id.to_i.to_i # Only Portage keep its original name and all other information
                    org.created_at = created 
                    org.target_url = Org.column_defaults["target_url"]
                    org.logo_uid = Org.column_defaults["logo_uid"]
                    org.logo_name = Org.column_defaults["logo_name"]
                    org.banner_name = Org.column_defaults["banner_name"]
                    org.contact_email = Faker::Internet.email
                    org.links = Org.column_defaults["links"]
                    org.contact_name = Faker::Name.name
                    if org.id == Rails.application.secrets.english_org_id.to_i
                        org.name = "Test Organization"
                        org.contact_email = "dmp.test.user.admin@engagedri.ca"
                        org.contact_name = "Test User"
                        org.abbreviation = "IEO"
                        org.language_id = 1 # English Default
                    elsif org.id == Rails.application.secrets.french_org_id.to_i
                        org.name = "Organisation de test"
                        org.contact_email = "dmp.utilisateur.test.admin@engagedri.ca"
                        org.contact_name = "Utilisateur test"
                        org.abbreviation = "OEO"
                        org.language_id = 2 # French Default
                    else
                        org.name = Faker::University.name
                        org.abbreviation = org.name + "_abbreviation"
                    end
                end
                serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Org.create!(#{serialized})"
            end
            QuestionFormat.all.each do |question_formats| 
                excluded_keys = ['created_at','updated_at'] 
                if question_formats.id == 7
                    question_formats.option_based = FALSE
                end
                serialized = question_formats.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "QuestionFormat.create(#{serialized})"
            end
        end
    end

    # seed2: guidance group and theme must be created before guidance and questions (using theme)
    desc "Export guidance group and theme format from 3.0.2 database to seeds_2.rb" 
    task :seed_2_export => :environment do
        file_name = 'db/seeds/sandbox/seeds_2.rb'
        File.delete(file_name) if File.exist?(file_name)
        excluded_keys =['created_at','updated_at'] 
        open(file_name, 'a') do |f|
            GuidanceGroup.all.each do |guidance_group| 
                serialized = guidance_group.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "GuidanceGroup.create!(#{serialized})"
            end 
            Theme.all.each do |theme| 
                serialized = theme.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Theme.create!(#{serialized})"
            end
        end
    end

    # seed3: guidance and template related components runs lastly
    desc "Export guidance and template_related content from 3.0.2 database to seeds_3.rb" 
    task :seed_3_export => :environment do
        file_name = 'db/seeds/sandbox/seeds_3.rb'
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
                f.puts "Template.create!(#{serialized})"
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
    # seed6: export all plan which org belongs to testers, this task generate the seed file that runs lastly
    desc "Export plan content from 3.0.2 database to seeds_6.rb" 
    task :seed_5_export => :environment do
        file_name = 'db/seeds/sandbox/seeds_5.rb'
        File.delete(file_name) if File.exist?(file_name)
        excluded_keys =['created_at','updated_at','start_date','end_date']
        org_list = [Rails.application.secrets.funder_org_id.to_i.to_i, Rails.application.secrets.english_org_id.to_i.to_i,Rails.application.secrets._org_id.to_i]
        open(file_name, 'a') do |f|
            Plan.where(org_id: org_list).all.each_with_index do |plan, index|
                plan.title = "Test Plan " + index.to_s
                plan.description = Faker::Lorem.sentence
                # force a few plan to use modified template from the two test organizations for statistics
                if [20..50].include?(index)
                    plan.template = Template.find(title: "Portage Template-Test1")
                elsif [60..90].include?(index)
                    plan.template = Template.find(title: "Portage Template-Test2")
                end
                serialized = plan.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Plan.create(#{serialized})"
                # import related roles
                Role.where(plan_id: plan.id).all.each do |role|
                    if plan.org_id == Rails.application.secrets.funder_org_id.to_i.to_i # change all user id to 1
                        role.user_id = 1
                    elsif plan.org_id == Rails.application.secrets.english_org_id.to_i # change all user id to 2
                        role.user_id = 2
                    else # change all user id to 3
                        role.user_id = 3
                    end
                    serialized = role.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                    f.puts "Role.create(#{serialized})"
                end
            end
        end
    end
end