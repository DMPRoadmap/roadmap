namespace :mysql_to_postgres do
    desc "Generate seed files"
    task retrieve_data: :environment do
        ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym) 
        # if we are going to do: rake export_production_data:build_sandbox_data RAILS_ENV=development, the line above can be eliminated. It is just to make sure we start from an env other than sandbox
        puts 'Make sure this task in running under production database instead of sandbox database.'
        puts 'Reminder: discuss with Neil to run on the most updated db on staging/production'
        puts "Read all data to staging-part1.rb" 
        Rake::Task['mysql_to_postgres:read_1'].execute
        puts "Read all data to staging-part2.rb" 
        Rake::Task['mysql_to_postgres:read_2'].execute
        puts "Read all data to staging-part3.rb" 
        Rake::Task['mysql_to_postgres:read_3'].execute
        # puts "Read all data to staging-part4.rb" 
        # Rake::Task['mysql_to_postgres:read_4'].execute
        # puts "Read all data to staging-part5.rb - the rest of the templates" 
        # Rake::Task['mysql_to_postgres:read_5'].execute
        # puts "Read all data to staging-part6.rb" 
        # Rake::Task['mysql_to_postgres:read_6'].execute
        puts 'Now, switch environment variable to use postgres database'
        puts 'Once you finish, run bin/rails db:reset'    
    end
    
    task :read_1 => :environment do
        file_name = 'db/seeds/staging/seeds_1.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] # exclude datetime fields
            # language
            puts 'loading languages...'
            Language.all.each do |language|
                serialized = language.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Language.create!(#{serialized})"
            end
            # region
            puts 'loading regions...'
            Region.all.each do |region|
                serialized = region.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                f.puts "Region.create!(#{serialized})"
            end
            # Token Permission Types
            puts 'loading token permission types...'
            TokenPermissionType.all.each do |tpt|
                ca = tpt.created_at.to_s
                ua = tpt.updated_at.to_s
                serialized = tpt.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "TokenPermissionType.create!(#{serialized})"
            end
            # Perm
            puts 'loading perms...'
            Perm.all.each do |perm|
                ca = perm.created_at.to_s
                ua = perm.updated_at.to_s
                serialized = perm.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "Perm.create!(#{serialized})"
            end
            # org
            puts 'loading orgs...'
            Org.all.each do |org|
                ca = org.created_at.to_s
                ua = org.updated_at.to_s
                serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "Org.create!(#{serialized})"
            end
            # departments
            
            # question format
            puts 'loading question formats'
            QuestionFormat.all.each do |question_formats| 
                ca = question_formats.created_at.to_s
                ua = question_formats.updated_at.to_s
                if question_formats.id == 7
                    question_formats.option_based = FALSE
                end
                serialized = question_formats.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "QuestionFormat.create(#{serialized})"
            end
        end
    end

    task :read_2 => :environment do
        file_name = 'db/seeds/staging/seeds_2.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] # exclude datetime fields
             # guidance group & theme
             puts 'loading guidance groups...'
             GuidanceGroup.all.each do |guidance_group| 
                 ca = guidance_group.created_at.to_s
                 ua = guidance_group.updated_at.to_s
                 serialized = guidance_group.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                 serialized["created_at"] = ca
                 serialized["updated_at"] = ua
                 f.puts "GuidanceGroup.create!(#{serialized})"
             end 
             puts 'loading themes...'
             Theme.all.each do |theme| 
                 ca = theme.created_at.to_s
                 ua = theme.updated_at.to_s
                 serialized = theme.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                 serialized["created_at"] = ca
                 serialized["updated_at"] = ua
                 f.puts "Theme.create!(#{serialized})"
             end
             # guidance & template-related: template, phase, sections, questions, annotations
             puts 'loading guidances...'
             GuidanceGroup.all.each do |guidance_group| # search through guidance group to grab all guidance_group.id
                 guidances = Guidance.where(:guidance_group_id => guidance_group.id) 
                 guidances.all.each do |guidance|
                     ca = guidance.created_at.to_s
                     ua = guidance.updated_at.to_s
                     serialized = guidance.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                     serialized["created_at"] = ca
                     serialized["updated_at"] = ua
                     f.puts "Guidance.create(#{serialized})"
                 end
             end       
            # notification
            puts 'loading notifications...notification must be manually transferred due to validation failure'
            # Notification.all.each do |no|
            #     ca = no.created_at.to_s
            #     ua = no.updated_at.to_s
            #     sa = no.starts_at.to_s
            #     ea = no.expires_at.to_s
            #     serialized = no.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
            #     serialized["created_at"] = ca
            #     serialized["updated_at"] = ua
            #     serialized["starts_at"] = sa
            #     serialized["expires_at"] = ea
            #     f.puts "Notification.create!(#{serialized})"
            # end
        end
    end

    # users needs to use raw sql to include all information
    # datetime: reset_password_sent_at, remember_created_at, current_sign_in_at, last_sign_in_at,
    # confirmed_at, confirmation_sent_at, invitation_created_at, invitation_sent_at, invitation_accepted_at, last_api_access
    task :read_3 => :environment do
        file_name = 'db/seeds/staging/seeds_3.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            timestamps = ['created_at',
                'updated_at',
                'reset_password_sent_at', 
                'remember_created_at', 
                'current_sign_in_at', 
                'last_sign_in_at',
                'confirmed_at', 
                'confirmation_sent_at', 
                'invitation_created_at', 
                'invitation_sent_at', 
                'invitation_accepted_at',
                'last_api_access'
            ]
            sql = "SELECT * FROM users"
            ActiveRecord::Base.connection.exec_query(sql).map do |user|
                user = user.with_indifferent_access.except(:encrypted_password)
                # verify the field that cause issue
                user[:password] = 'test_password'
                puts 'loading users ' + user[:id].to_s + " now...could take a while"
                timestamps.each { |ek|  user[ek.to_sym] = user[ek.to_sym].to_s }
                f.puts "User.create(#{user})"
            end
        end
    end

    task :read_4 => :environment do
        file_name = 'db/seeds/staging/seeds_4.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] # exclude datetime fields
            ActiveRecord::Base.connection.exec_query("select * from templates").map do |template|
                puts 'loading template ' + template.id.to_s + " now...could take a while"
                ca = template.created_at.to_s
                ua = template.updated_at.to_s
                serialized = template.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "Template.create!(#{serialized})"
                # create phases
                phases = Phase.where(:template_id => template.id) # retrieve template old id
                phases.all.each do |phase|
                    ca = phase.created_at.to_s
                    ua = phase.updated_at.to_s
                    serialized = phase.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                    serialized["created_at"] = ca
                    serialized["updated_at"] = ua
                    f.puts "Phase.create(#{serialized})"
                    # create sections
                    sections = Section.where(:phase_id => phase.id)
                    sections.all.each do |section|
                        ca = section.created_at.to_s
                        ua = section.updated_at.to_s
                        serialized = section.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                        serialized["created_at"] = ca
                        serialized["updated_at"] = ua
                        f.puts "Section.create(#{serialized})"
                        # create questions
                        questions = Question.where(:section_id => section.id)
                        questions.all.each do |question|
                            ca = question.created_at.to_s
                            ua = question.updated_at.to_s
                            serialized = question.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                            serialized["created_at"] = ca
                            serialized["updated_at"] = ua
                            f.puts "Question.create(#{serialized})"
                            # create question options
                            question_options = QuestionOption.where(:question_id => question.id)
                            question_options.all.each do |question_option|
                                ca = question_option.created_at.to_s
                                ua = question_option.updated_at.to_s
                                serialized = question_option.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                                serialized["created_at"] = ca
                                serialized["updated_at"] = ua
                                f.puts "QuestionOption.create(#{serialized})"
                            end
                            # create annotations
                            annotations = Annotation.where(:question_id => question.id)
                            annotations.all.each do |annotation|
                                ca = annotation.created_at.to_s
                                ua = annotation.updated_at.to_s
                                serialized = annotation.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                                serialized["created_at"] = ca
                                serialized["updated_at"] = ua
                                f.puts "Annotation.create(#{serialized})"
                            end
                        end
                    end
                end
            end
        end
    end
    
    task :read_5 => :environment do
        file_name = 'db/seeds/staging/seeds_5.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] # exclude datetime fields
            Template.where(id: 10000..).each do |template|
                puts 'loading template ' + template.id.to_s + " now...could take a while"
                ca = template.created_at.to_s
                ua = template.updated_at.to_s
                serialized = template.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "Template.create!(#{serialized})"
                # create phases
                phases = Phase.where(:template_id => template.id) # retrieve template old id
                phases.all.each do |phase|
                    ca = phase.created_at.to_s
                    ua = phase.updated_at.to_s
                    serialized = phase.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                    serialized["created_at"] = ca
                    serialized["updated_at"] = ua
                    f.puts "Phase.create(#{serialized})"
                    # create sections
                    sections = Section.where(:phase_id => phase.id)
                    sections.all.each do |section|
                        ca = section.created_at.to_s
                        ua = section.updated_at.to_s
                        serialized = section.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                        serialized["created_at"] = ca
                        serialized["updated_at"] = ua
                        f.puts "Section.create(#{serialized})"
                        # create questions
                        questions = Question.where(:section_id => section.id)
                        questions.all.each do |question|
                            ca = question.created_at.to_s
                            ua = question.updated_at.to_s
                            serialized = question.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                            serialized["created_at"] = ca
                            serialized["updated_at"] = ua
                            f.puts "Question.create(#{serialized})"
                            # create question options
                            question_options = QuestionOption.where(:question_id => question.id)
                            question_options.all.each do |question_option|
                                ca = question_option.created_at.to_s
                                ua = question_option.updated_at.to_s
                                serialized = question_option.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                                serialized["created_at"] = ca
                                serialized["updated_at"] = ua
                                f.puts "QuestionOption.create(#{serialized})"
                            end
                            # create annotations
                            annotations = Annotation.where(:question_id => question.id)
                            annotations.all.each do |annotation|
                                ca = annotation.created_at.to_s
                                ua = annotation.updated_at.to_s
                                serialized = annotation.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                                serialized["created_at"] = ca
                                serialized["updated_at"] = ua
                                f.puts "Annotation.create(#{serialized})"
                            end
                        end
                    end
                end
            end
        end
    end
    
    # Users and plans must come before the roles
    task :read_6 => :environment do
        file_name = 'db/seeds/staging/seeds_6.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            excluded_keys = ['created_at','updated_at'] # exclude datetime fields
            puts 'loading identifier schemes...'
            IdentifierScheme.all.each do |is|
                ca = is.created_at.to_s
                ua = is.updated_at.to_s
                serialized = is.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "IdentifierScheme.create!(#{serialized})"
            end
            puts 'loading identifiers...'
            Identifier.all.each do |id|
                ca = id.created_at.to_s
                ua = id.updated_at.to_s
                serialized = id.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "Identifier.create!(#{serialized})"
            end
            puts 'loading plans...'
            Plan.all.each do |plan|
                ca = plan.created_at.to_s
                ua = plan.updated_at.to_s
                sd = plan.start_date.to_s
                ed = plan.end_date.to_s
                serialized = plan.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                serialized["start_date"] = sd
                serialized["end_date"] = ed
                f.puts "Plan.create!(#{serialized})"
            end    
            puts 'loading roles...'
            Role.all.each do |role|
                ca = role.created_at.to_s
                ua = role.updated_at.to_s
                serialized = role.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                serialized["created_at"] = ca
                serialized["updated_at"] = ua
                f.puts "Role.create!(#{serialized})"
            end    
        end
    end
end
