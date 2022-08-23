require 'json'
namespace :mysql_to_postgres do
    desc "Generate seed files"
    task retrieve_data: :environment do
        ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym) 
        # if we are going to do: rake export_production_data:build_sandbox_data RAILS_ENV=development, the line above can be eliminated. It is just to make sure we start from an env other than sandbox
        puts 'Make sure this task in running under production database instead of sandbox database.'
        puts 'Make sure you have /db/seeds/staging/temp folder created.'
        puts "Read all data to staging-part0.rb" 
        Rake::Task['mysql_to_postgres:read_0'].execute
        puts "Read all data to staging-part1.rb" 
        Rake::Task['mysql_to_postgres:read_1'].execute
        puts "Read all data to staging-part2.rb"  # load users
        Rake::Task['mysql_to_postgres:read_2'].execute
        # puts "Read all data to staging-part4.rb" 
        # Rake::Task['mysql_to_postgres:read_4'].execute
        # puts "Read all data to staging-part5.rb - the rest of the templates" 
        # Rake::Task['mysql_to_postgres:read_5'].execute
        # puts "Read all data to staging-part6.rb" 
        # Rake::Task['mysql_to_postgres:read_6'].execute
        puts '...Now, switch environment variable to use postgres database'
        # puts 'Run the following step by step'
        # puts '1. bin/rails db:drop (you can ignore error message if you never create the db before)' 
        # puts '2. bin/rails db:create'
        # puts '3. bin/rails db:migrate' 
        # puts '4. bin/rails before_seeds:copy_data'
        # puts '5. bin/rails db:seed'
        # puts '6. bin/rails rewrite_postgres:retrieve_data'    
    end
    
    task :read_0 => :environment do
        file_name = 'db/seeds/staging/seeds_0.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, 'a') do |f|
            # language - no timestamp
            puts 'loading languages...'
            sql = "SELECT * FROM languages"
            ActiveRecord::Base.connection.exec_query(sql).map do |language|
                language = language.with_indifferent_access
                f.puts "Language.create!(#{language})"
            end
            # region - no timestamp
            puts 'loading regions...'
            sql = "SELECT * FROM regions"
            ActiveRecord::Base.connection.exec_query(sql).map do |region|
                region = region.with_indifferent_access
                f.puts "Region.create!(#{region})"
            end
            # Token Permission Types
            puts 'loading token permission types...'
            sql = "SELECT * FROM token_permission_types"
            timestamps = ['created_at',
                'updated_at'
            ]
            ActiveRecord::Base.connection.exec_query(sql).map do |tpt|
                tpt = tpt.with_indifferent_access
                timestamps.each { |ek|  tpt[ek.to_sym] = tpt[ek.to_sym].to_s }
                f.puts "TokenPermissionType.create!(#{tpt})"
            end
            # Perm
            puts 'loading perms...'
            sql = "SELECT * FROM perms"
            timestamps = ['created_at',
                'updated_at'
            ]
            ActiveRecord::Base.connection.exec_query(sql).map do |perm|
                perm = perm.with_indifferent_access
                timestamps.each { |ek|  perm[ek.to_sym] = perm[ek.to_sym].to_s }
                f.puts "Perm.create!(#{perm})"
            end
            # Orgs
            puts 'loading orgs...'
            sql = "SELECT * FROM orgs"
            timestamps = ['created_at',
                'updated_at'
            ]
            hashs = ['links']
            ActiveRecord::Base.connection.exec_query(sql).map do |org|
                org = org.with_indifferent_access
                timestamps.each { |ek|  org[ek.to_sym] = org[ek.to_sym].to_s }
                hashs.each { |ha| org[ha.to_sym] = JSON.parse(org[ha.to_sym].gsub("=>", ":").gsub(":nil,", ":null,"))}
                f.puts "Org.create!(#{org})"
            end
            # departments - org needs to exist first
            puts 'loading departments...'
            sql = "SELECT * FROM departments"
            timestamps = ['created_at',
                'updated_at'
            ]
            ActiveRecord::Base.connection.exec_query(sql).map do |dept|
                dept = dept.with_indifferent_access
                timestamps.each { |ek|  dept[ek.to_sym] = dept[ek.to_sym].to_s }
                f.puts "Department.create!(#{dept})"
            end
            # question format
            puts 'loading question formats...'
            sql = "SELECT * FROM question_formats"
            timestamps = ['created_at',
                'updated_at'
            ]
            ActiveRecord::Base.connection.exec_query(sql).map do |q_f|
                q_f = q_f.with_indifferent_access
                timestamps.each { |ek|  q_f[ek.to_sym] = q_f[ek.to_sym].to_s }
                f.puts "QuestionFormat.create!(#{q_f})"
            end
            
        end
    end

    # all guidance-related info here needs to be written in SQL due to constraints
    task :read_1 => :environment do
        # file_name = 'db/seeds/staging/seeds_2.rb'
        # File.delete(file_name) if File.exist?(file_name)
        # theme
        themes = []
        puts 'loading themes...'
        sql = "SELECT * FROM themes"
        timestamps = ['created_at',
        'updated_at'
        ]
        ActiveRecord::Base.connection.exec_query(sql).map do |theme|
            theme = theme.with_indifferent_access
            timestamps.each { |ek|  theme[ek.to_sym] = theme[ek.to_sym].to_s }
            themes << theme
        end
        file_name = 'db/seeds/staging/temp/themes.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(themes))
        # guidance group
        ggs = []
        puts 'loading guidance groups...'
        sql = "SELECT * FROM guidance_groups"
        timestamps = ['created_at',
        'updated_at'
        ]
        ActiveRecord::Base.connection.exec_query(sql).map do |guidance_group|
            guidance_group = guidance_group.with_indifferent_access
            timestamps.each { |ek|  guidance_group[ek.to_sym] = guidance_group[ek.to_sym].to_s }
            ggs << guidance_group
        end
        file_name = 'db/seeds/staging/temp/guidance_groups.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(ggs))
        # theme
        # themes_in_guidance
        puts 'loading guidances and themes_in_guidance...'
        sql = "SELECT * FROM themes_in_guidance"
        t_i_gs = []
        ActiveRecord::Base.connection.exec_query(sql).map do |t_i_g|
           t_i_g = t_i_g.with_indifferent_access
           t_i_gs << t_i_g
        end
        file_name = 'db/seeds/staging/temp/themes_in_guidance.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(t_i_gs))
        # guidances
        sql = "SELECT * FROM guidances"
        timestamps = ['created_at',
           'updated_at'
        ]
        gs = []
        ActiveRecord::Base.connection.exec_query(sql).map do |g|
            g = g.with_indifferent_access
            timestamps.each { |ek|  g[ek.to_sym] = g[ek.to_sym].to_s }
            gs << g
        end
        file_name = 'db/seeds/staging/temp/guidances.rb'
           File.delete(file_name) if File.exist?(file_name)
           File.write(file_name, JSON.dump(gs))
        # guidance_in_group
        gigs = []
        puts 'loading guidance_in_group...'
        sql = "SELECT * FROM guidance_in_group"
        ActiveRecord::Base.connection.exec_query(sql).map do |gig|
            gig = gig.with_indifferent_access
            gigs << gig
        end
        file_name = 'db/seeds/staging/temp/guidance_in_group.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(gigs))
        # guidance_translations
        gts = []
        timestamps = ['created_at',
            'updated_at'
         ]
        puts 'loading guidance_translations...'
        sql = "SELECT * FROM guidance_translations"
        ActiveRecord::Base.connection.exec_query(sql).map do |gt|
            gt = gt.with_indifferent_access
            timestamps.each { |ek|  gt[ek.to_sym] = gt[ek.to_sym].to_s }
            gts << gt
        end
        file_name = 'db/seeds/staging/temp/guidance_translations.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(gts))
        # notification
        sql = "SELECT * FROM notifications"
        timestamps = ['created_at',
            'updated_at',
            'starts_at',
            'expires_at'
        ]
        nts = []
        ActiveRecord::Base.connection.exec_query(sql).map do |notification|
            notification = notification.with_indifferent_access
            nts << notification
        end
        file_name = 'db/seeds/staging/temp/notifications.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(nts))
        # notification acknowledgements
        ntas = []
        sql = "SELECT * FROM notification_acknowledgements"
        ActiveRecord::Base.connection.exec_query(sql).map do |n_a|
            n_a = n_a.with_indifferent_access
            ntas << n_a
        end
        file_name = 'db/seeds/staging/temp/notification_acknowledgements.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(ntas))
    end
    
    task :read_2 => :environment do
        passwords = []
        users = []
        puts 'loading users...could take a while'
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
            user = user.with_indifferent_access
            timestamps.each do |ek| 
                if user[ek.to_sym].present? 
                    user[ek.to_sym] =  user[ek.to_sym].to_s 
                else 
                    user[ek.to_sym] = nil 
                end
                # p user[ek.to_sym]
            end
            # user[:password] = 'test_password'
            # passwords << {"id"=>user[:id], "encrypted_password"=>user[:encrypted_password]}
            # user.except(:encrypted_password)
            
            users << user
        end
        file_name = 'db/seeds/staging/temp/users.rb'
        File.delete(file_name) if File.exist?(file_name)
        File.write(file_name, JSON.dump(users))
        #### Pending for remove?
        # file_name = 'db/seeds/staging/temp/encrypted_passwords.rb'
        # File.delete(file_name) if File.exist?(file_name)
        # File.write(file_name, JSON.dump(passwords))
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
                            # question format translations
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
