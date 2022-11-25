# frozen_string_literal: true

require 'json'
namespace :mysql_to_postgres do
  desc 'Generate seed files'
  task retrieve_data: :environment do
    ActiveRecord::Base.establish_connection(Rails.env.to_s.to_sym)
    puts 'Make sure this task in running under production database instead of sandbox database.'
    puts 'Make sure you have /db/seeds/staging/temp folder created.'
    puts 'Read all data to staging-part0.rb'
    Rake::Task['mysql_to_postgres:read0'].execute
    puts 'Read all data to staging-part1.rb'
    Rake::Task['mysql_to_postgres:read1'].execute
    puts 'Read all data to staging-part2.rb'
    Rake::Task['mysql_to_postgres:read2'].execute
    puts 'Read all data to staging-part3.rb'
    Rake::Task['mysql_to_postgres:read3'].execute
    puts 'Read all data to staging-part4.rb'
    Rake::Task['mysql_to_postgres:read4'].execute
    puts 'Read all data to staging-part5.rb'
    Rake::Task['mysql_to_postgres:read5'].execute
    puts 'Read all data to staging-part6.rb'
    Rake::Task['mysql_to_postgres:read6'].execute
    puts 'Read all data to staging-part7.rb'
    Rake::Task['mysql_to_postgres:read7'].execute
    puts '...Now, switch environment variable to use postgres database'
  end

  # separate entities that will generate SEED file
  task read0: :environment do
    file_name = 'db/seeds/staging/seeds_0.rb'
    FileUtils.rm_f(file_name)
    File.open(file_name, 'a') do |f|
      # language - no timestamp
      puts 'loading languages...'
      sql = 'SELECT * FROM languages'
      ActiveRecord::Base.connection.exec_query(sql).map do |language|
        language = language.with_indifferent_access
        f.puts "Language.create!(#{language})"
      end
      # region - no timestamp
      puts 'loading regions...'
      sql = 'SELECT * FROM regions'
      ActiveRecord::Base.connection.exec_query(sql).map do |region|
        region = region.with_indifferent_access
        f.puts "Region.create!(#{region})"
      end
      # Token Permission Types
      puts 'loading token permission types...'
      sql = 'SELECT * FROM token_permission_types'
      timestamps = %w[created_at
                      updated_at]
      ActiveRecord::Base.connection.exec_query(sql).map do |tpt|
        tpt = tpt.with_indifferent_access
        timestamps.each { |ek| tpt[ek.to_sym] = tpt[ek.to_sym].to_s }
        f.puts "TokenPermissionType.create!(#{tpt})"
      end
      # Perm
      puts 'loading perms...'
      sql = 'SELECT * FROM perms'
      timestamps = %w[created_at
                      updated_at]
      ActiveRecord::Base.connection.exec_query(sql).map do |perm|
        perm = perm.with_indifferent_access
        timestamps.each { |ek| perm[ek.to_sym] = perm[ek.to_sym].to_s }
        f.puts "Perm.create!(#{perm})"
      end
      # Orgs
      puts 'loading orgs...'
      sql = 'SELECT * FROM orgs'
      timestamps = %w[created_at
                      updated_at]
      hashs = ['links']
      ActiveRecord::Base.connection.exec_query(sql).map do |org|
        org = org.with_indifferent_access
        timestamps.each { |ek| org[ek.to_sym] = org[ek.to_sym].to_s }
        hashs.each { |ha| org[ha.to_sym] = JSON.parse(org[ha.to_sym].gsub('=>', ':').gsub(':nil,', ':null,')) }
        f.puts "Org.create!(#{org})"
      end
      # departments - org needs to exist first
      puts 'loading departments...'
      sql = 'SELECT * FROM departments'
      timestamps = %w[created_at
                      updated_at]
      ActiveRecord::Base.connection.exec_query(sql).map do |dept|
        dept = dept.with_indifferent_access
        timestamps.each { |ek| dept[ek.to_sym] = dept[ek.to_sym].to_s }
        f.puts "Department.create!(#{dept})"
      end
      # question format
      puts 'loading question formats...'
      sql = 'SELECT * FROM question_formats'
      timestamps = %w[created_at
                      updated_at]
      ActiveRecord::Base.connection.exec_query(sql).map do |q_f|
        q_f = q_f.with_indifferent_access
        timestamps.each { |ek| q_f[ek.to_sym] = q_f[ek.to_sym].to_s }
        f.puts "QuestionFormat.create!(#{q_f})"
      end
    end
  end

  # guidance-related
  task read1: :environment do
    # theme
    themes = []
    puts 'loading themes...'
    sql = 'SELECT * FROM themes'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |theme|
      theme = theme.with_indifferent_access
      timestamps.each { |ek| theme[ek.to_sym] = theme[ek.to_sym].to_s }
      themes << theme
    end
    file_name = 'db/seeds/staging/temp/themes.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(themes))
    # guidance group
    ggs = []
    puts 'loading guidance groups...'
    sql = 'SELECT * FROM guidance_groups'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |guidance_group|
      guidance_group = guidance_group.with_indifferent_access
      timestamps.each { |ek| guidance_group[ek.to_sym] = guidance_group[ek.to_sym].to_s }
      ggs << guidance_group
    end
    file_name = 'db/seeds/staging/temp/guidance_groups.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(ggs))
    # themes_in_guidance
    puts 'loading guidances and themes_in_guidance...'
    sql = 'SELECT * FROM themes_in_guidance'
    t_i_gs = []
    ActiveRecord::Base.connection.exec_query(sql).map do |t_i_g|
      t_i_g = t_i_g.with_indifferent_access
      t_i_gs << t_i_g
    end
    file_name = 'db/seeds/staging/temp/themes_in_guidance.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(t_i_gs))
    # guidances
    sql = 'SELECT * FROM guidances'
    timestamps = %w[created_at
                    updated_at]
    gs = []
    ActiveRecord::Base.connection.exec_query(sql).map do |g|
      g = g.with_indifferent_access
      timestamps.each { |ek| g[ek.to_sym] = g[ek.to_sym].to_s }
      gs << g
    end
    file_name = 'db/seeds/staging/temp/guidances.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(gs))
    # guidance_in_group
    gigs = []
    puts 'loading guidance_in_group...'
    sql = 'SELECT * FROM guidance_in_group'
    ActiveRecord::Base.connection.exec_query(sql).map do |gig|
      gig = gig.with_indifferent_access
      gigs << gig
    end
    file_name = 'db/seeds/staging/temp/guidance_in_group.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(gigs))
    # guidance_translations
    gts = []
    timestamps = %w[created_at
                    updated_at]
    puts 'loading guidance_translations...'
    sql = 'SELECT * FROM guidance_translations'
    ActiveRecord::Base.connection.exec_query(sql).map do |gt|
      gt = gt.with_indifferent_access
      timestamps.each { |ek| gt[ek.to_sym] = gt[ek.to_sym].to_s }
      gts << gt
    end
    file_name = 'db/seeds/staging/temp/guidance_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(gts))
    # notification
    sql = 'SELECT * FROM notifications'
    timestamps = %w[created_at
                    updated_at
                    starts_at
                    expires_at]
    nts = []
    ActiveRecord::Base.connection.exec_query(sql).map do |notification|
      notification = notification.with_indifferent_access
      timestamps.each { |ek| notification[ek.to_sym] = notification[ek.to_sym].to_s }
      nts << notification
    end
    file_name = 'db/seeds/staging/temp/notifications.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(nts))
    # notification acknowledgements
    ntas = []
    sql = 'SELECT * FROM notification_acknowledgements'
    ActiveRecord::Base.connection.exec_query(sql).map do |n_a|
      n_a = n_a.with_indifferent_access
      ntas << n_a
    end
    file_name = 'db/seeds/staging/temp/notification_acknowledgements.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(ntas))
  end

  # users and users_perms, user_statuses, user_types
  task read2: :environment do
    # users
    users = []
    puts 'loading users...could take a while'
    timestamps = %w[created_at
                    updated_at
                    reset_password_sent_at
                    remember_created_at
                    current_sign_in_at
                    last_sign_in_at
                    confirmed_at
                    confirmation_sent_at
                    invitation_created_at
                    invitation_sent_at
                    invitation_accepted_at
                    last_api_access]
    sql = 'SELECT * FROM users'
    ActiveRecord::Base.connection.exec_query(sql).map do |user|
      user = user.with_indifferent_access
      timestamps.each do |ek|
        user[ek.to_sym] = (user[ek.to_sym].to_s if user[ek.to_sym].present?)
      end
      users << user
    end
    file_name = 'db/seeds/staging/temp/users.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(users))
    # users_perms
    users_perms = []
    puts 'loading users_perms'
    sql = 'SELECT * FROM users_perms'
    ActiveRecord::Base.connection.exec_query(sql).map do |users_perm|
      users_perm = users_perm.with_indifferent_access
      users_perms << users_perm
    end
    file_name = 'db/seeds/staging/temp/users_perms.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(users_perms))
    # user_statuse
    user_statuses = []
    puts 'loading user_statuses'
    sql = 'SELECT * FROM user_statuses'
    ActiveRecord::Base.connection.exec_query(sql).map do |user_statuse|
      user_statuse = user_statuse.with_indifferent_access
      user_statuses << user_statuse
    end
    file_name = 'db/seeds/staging/temp/user_statuses.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(user_statuses))
    # user_types
    user_types = []
    puts 'loading user_types'
    sql = 'SELECT * FROM user_types'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |user_type|
      user_type = user_type.with_indifferent_access
      timestamps.each { |ek| user_type[ek.to_sym] = user_type[ek.to_sym].to_s }
      user_types << user_type
    end
    file_name = 'db/seeds/staging/temp/user_types.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(user_types))
  end

  # template-related & question-related
  task read3: :environment do
    # templates
    puts 'loading templates'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM templates'
    templates = []
    ActiveRecord::Base.connection.exec_query(sql).map do |template|
      template = template.with_indifferent_access
      timestamps.each { |ek| template[ek.to_sym] = template[ek.to_sym].to_s }
      templates << template
    end
    file_name = 'db/seeds/staging/temp/templates.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(templates))
    # phases & phase_translations
    puts 'loading phases'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM phases'
    phases = []
    ActiveRecord::Base.connection.exec_query(sql).map do |phase|
      phase = phase.with_indifferent_access
      timestamps.each { |ek| phase[ek.to_sym] = phase[ek.to_sym].to_s }
      phases << phase
    end
    file_name = 'db/seeds/staging/temp/phases.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(phases))
    puts 'loading phase_translations'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM phase_translations'
    phase_translations = []
    ActiveRecord::Base.connection.exec_query(sql).map do |p_t|
      p_t = p_t.with_indifferent_access
      timestamps.each { |ek| p_t[ek.to_sym] = p_t[ek.to_sym].to_s }
      phase_translations << p_t
    end
    file_name = 'db/seeds/staging/temp/phase_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(phase_translations))
    # sections & section_translations
    puts 'loading sections'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM sections'
    sections = []
    ActiveRecord::Base.connection.exec_query(sql).map do |section|
      section = section.with_indifferent_access
      timestamps.each { |ek| section[ek.to_sym] = section[ek.to_sym].to_s }
      sections << section
    end
    file_name = 'db/seeds/staging/temp/sections.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(sections))
    puts 'loading section_translations'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM section_translations'
    section_translations = []
    ActiveRecord::Base.connection.exec_query(sql).map do |s_t|
      s_t = s_t.with_indifferent_access
      timestamps.each { |ek|  s_t[ek.to_sym] = s_t[ek.to_sym].to_s }
      section_translations << s_t
    end
    file_name = 'db/seeds/staging/temp/section_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(section_translations))
    # questions & question_translations
    puts 'loading questions'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM questions'
    questions = []
    ActiveRecord::Base.connection.exec_query(sql).map do |question|
      question = question.with_indifferent_access

      p "question: id is #{question['id']}"
      p "question: section_id is #{question['section_id']}"

      timestamps.each { |ek|  question[ek.to_sym] = question[ek.to_sym].to_s }
      questions << question
    end
    file_name = 'db/seeds/staging/temp/questions.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(questions))
    puts 'loading question_translations'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM question_translations'
    question_translations = []
    ActiveRecord::Base.connection.exec_query(sql).map do |q_t|
      q_t = q_t.with_indifferent_access
      timestamps.each { |ek| q_t[ek.to_sym] = q_t[ek.to_sym].to_s }
      question_translations << q_t
    end
    file_name = 'db/seeds/staging/temp/question_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(question_translations))
    # question_formats & question_format_translations
    puts 'loading question_formats'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM question_formats'
    question_formats = []
    ActiveRecord::Base.connection.exec_query(sql).map do |question_format|
      question_format = question_format.with_indifferent_access
      timestamps.each { |ek| question_format[ek.to_sym] = question_format[ek.to_sym].to_s }
      question_formats << question_format
    end
    file_name = 'db/seeds/staging/temp/question_formats.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(question_formats))
    puts 'loading question_format_translations'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM question_format_translations'
    question_format_translations = []
    ActiveRecord::Base.connection.exec_query(sql).map do |q_f_t|
      q_f_t = q_f_t.with_indifferent_access
      timestamps.each { |ek| q_f_t[ek.to_sym] = q_f_t[ek.to_sym].to_s }
      question_format_translations << q_f_t
    end
    file_name = 'db/seeds/staging/temp/question_format_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(question_format_translations))
    # options ( option_warnings is empty)
    sql = 'SELECT * FROM options'
    options = []
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |option|
      option = option.with_indifferent_access
      timestamps.each { |ek| option[ek.to_sym] = option[ek.to_sym].to_s }
      options << option
    end
    file_name = 'db/seeds/staging/temp/options.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(options))
    # question_options. Some of q_o doesn't have created_at and updated_at, thus assign nil
    puts 'loading question_options'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM question_options'
    question_options = []
    ActiveRecord::Base.connection.exec_query(sql).map do |question_option|
      question_option = question_option.with_indifferent_access
      timestamps.each do |ek|
        question_option[ek.to_sym] = (question_option[ek.to_sym].to_s if question_option[ek.to_sym].present?)
      end
      question_options << question_option
    end
    file_name = 'db/seeds/staging/temp/question_options.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(question_options))
    # questions_themes
    puts 'loading questions_themes'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM questions_themes'
    questions_themes = []
    ActiveRecord::Base.connection.exec_query(sql).map do |questions_theme|
      questions_theme = questions_theme.with_indifferent_access
      timestamps.each { |ek| questions_theme[ek.to_sym] = questions_theme[ek.to_sym].to_s }
      questions_themes << questions_theme
    end
    file_name = 'db/seeds/staging/temp/questions_themes.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(questions_themes))
    # conditions
    puts 'loading conditions'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM conditions'
    conditions = []
    ActiveRecord::Base.connection.exec_query(sql).map do |condition|
      condition = condition.with_indifferent_access
      timestamps.each { |ek| condition[ek.to_sym] = condition[ek.to_sym].to_s }
      conditions << condition
    end
    file_name = 'db/seeds/staging/temp/conditions.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(conditions))
  end

  # plan-related
  task read4: :environment do
    # identifier schemes
    identifier_schemes = []
    puts 'loading identifier_schemes'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM identifier_schemes'
    ActiveRecord::Base.connection.exec_query(sql).map do |identifier_scheme|
      identifier_scheme = identifier_scheme.with_indifferent_access
      timestamps.each { |ek| identifier_scheme[ek.to_sym] = identifier_scheme[ek.to_sym].to_s }
      identifier_schemes << identifier_scheme
    end
    file_name = 'db/seeds/staging/temp/identifier_schemes.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(identifier_schemes))
    # identifiers
    identifiers = []
    puts 'loading identifiers'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM identifiers'
    ActiveRecord::Base.connection.exec_query(sql).map do |identifier|
      identifier = identifier.with_indifferent_access
      timestamps.each { |ek| identifier[ek.to_sym] = identifier[ek.to_sym].to_s }
      identifiers << identifier
    end
    file_name = 'db/seeds/staging/temp/identifiers.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(identifiers))
    # plans
    plans = []
    puts 'loading plans'
    timestamps = %w[created_at
                    updated_at
                    start_date
                    end_date]
    sql = 'SELECT * FROM plans'
    ActiveRecord::Base.connection.exec_query(sql).map do |plan|
      plan = plan.with_indifferent_access
      timestamps.each { |ek| plan[ek.to_sym] = plan[ek.to_sym].to_s }
      plans << plan
    end
    file_name = 'db/seeds/staging/temp/plans.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(plans))
    # plan_sections
    plan_sections = []
    puts 'loading plan_sections'
    timestamps = %w[created_at
                    updated_at release_time]
    sql = 'SELECT * FROM plan_sections'
    ActiveRecord::Base.connection.exec_query(sql).map do |plan_section|
      plan_section = plan_section.with_indifferent_access
      timestamps.each { |ek| plan_section[ek.to_sym] = plan_section[ek.to_sym].to_s }
      plan_sections << plan_section
    end
    file_name = 'db/seeds/staging/temp/plan_sections.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(plan_sections))
    # plans_guidance_groups
    plans_guidance_groups = []
    puts 'loading plans_guidance_groups'
    sql = 'SELECT * FROM plans_guidance_groups'
    ActiveRecord::Base.connection.exec_query(sql).map do |plans_guidance_group|
      plans_guidance_group = plans_guidance_group.with_indifferent_access
      plans_guidance_groups << plans_guidance_group
    end
    file_name = 'db/seeds/staging/temp/plans_guidance_groups.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(plans_guidance_groups))
    # roles
    roles = []
    puts 'loading roles'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM roles'
    ActiveRecord::Base.connection.exec_query(sql).map do |role|
      role = role.with_indifferent_access
      timestamps.each { |ek| role[ek.to_sym] = role[ek.to_sym].to_s }
      roles << role
    end
    file_name = 'db/seeds/staging/temp/roles.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(roles))
    # users_roles
    users_roles = []
    puts 'loading users_roles'
    sql = 'SELECT * FROM users_roles'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |users_role|
      users_role = users_role.with_indifferent_access
      timestamps.each { |ek| users_role[ek.to_sym] = users_role[ek.to_sym].to_s }
      users_roles << users_role
    end
    file_name = 'db/seeds/staging/temp/users_roles.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(users_roles))
    # contributors
    contributors = []
    puts 'loading contributors'
    sql = 'SELECT * FROM contributors'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |contributor|
      contributor = contributor.with_indifferent_access
      timestamps.each { |ek| contributor[ek.to_sym] = contributor[ek.to_sym].to_s }
      contributors << contributor
    end
    file_name = 'db/seeds/staging/temp/contributors.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(contributors))
    # comments
    comments = []
    puts 'loading comments'
    sql = 'SELECT * FROM comments'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |comment|
      comment = comment.with_indifferent_access
      timestamps.each { |ek| comment[ek.to_sym] = comment[ek.to_sym].to_s }
      comments << comment
    end
    file_name = 'db/seeds/staging/temp/comments.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(comments))
    # versions
    versions = []
    puts 'loading versions'
    sql = 'SELECT * FROM versions'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |version|
      version = version.with_indifferent_access
      timestamps.each { |ek| version[ek.to_sym] = version[ek.to_sym].to_s }
      versions << version
    end
    file_name = 'db/seeds/staging/temp/versions.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(versions))
    # version_translations
    version_translations = []
    puts 'loading version_translations'
    sql = 'SELECT * FROM version_translations'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |version_translation|
      version_translation = version_translation.with_indifferent_access
      timestamps.each { |ek| version_translation[ek.to_sym] = version_translation[ek.to_sym].to_s }
      version_translations << version_translation
    end
    file_name = 'db/seeds/staging/temp/version_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(version_translations))
    # exported_plans
    exported_plans = []
    puts 'loading exported_plans'
    sql = 'SELECT * FROM exported_plans'
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |exported_plan|
      exported_plan = exported_plan.with_indifferent_access
      timestamps.each { |ek| exported_plan[ek.to_sym] = exported_plan[ek.to_sym].to_s }
      exported_plans << exported_plan
    end
    file_name = 'db/seeds/staging/temp/exported_plans.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(exported_plans))
  end

  # organisations, annotations, answers, projects
  task read5: :environment do
    # organisations, organisation_types, org_token_permissions
    puts 'loading organisations...'
    sql = 'SELECT * FROM organisations'
    organisations = []
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |organisation|
      organisation = organisation.with_indifferent_access
      timestamps.each { |ek| organisation[ek.to_sym] = organisation[ek.to_sym].to_s }
      organisations << organisation
    end
    file_name = 'db/seeds/staging/temp/organisations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(organisations))
    puts 'loading organisation_types...'
    sql = 'SELECT * FROM organisation_types'
    organisation_types = []
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |organisation_type|
      organisation_type = organisation_type.with_indifferent_access
      timestamps.each { |ek| organisation_type[ek.to_sym] = organisation_type[ek.to_sym].to_s }
      organisation_types << organisation_type
    end
    file_name = 'db/seeds/staging/temp/organisation_types.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(organisation_types))
    puts 'loading org_token_permissions...'
    sql = 'SELECT * FROM org_token_permissions'
    org_token_permissions = []
    timestamps = %w[created_at
                    updated_at]
    ActiveRecord::Base.connection.exec_query(sql).map do |org_token_permission|
      org_token_permission = org_token_permission.with_indifferent_access
      timestamps.each { |ek| org_token_permission[ek.to_sym] = org_token_permission[ek.to_sym].to_s }
      org_token_permissions << org_token_permission
    end
    file_name = 'db/seeds/staging/temp/org_token_permissions.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(org_token_permissions))
    # annotations
    annotations = []
    puts 'loading annotations'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM annotations'
    ActiveRecord::Base.connection.exec_query(sql).map do |annotation|
      annotation = annotation.with_indifferent_access
      timestamps.each { |ek| annotation[ek.to_sym] = annotation[ek.to_sym].to_s }
      annotations << annotation
    end
    file_name = 'db/seeds/staging/temp/annotations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(annotations))
    # answers
    answers = []
    puts 'loading answers'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM answers'
    ActiveRecord::Base.connection.exec_query(sql).map do |answer|
      answer = answer.with_indifferent_access
      timestamps.each { |ek| answer[ek.to_sym] = answer[ek.to_sym].to_s }
      answers << answer
    end
    file_name = 'db/seeds/staging/temp/answers.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(answers))
    # answers_options
    answers_options = []
    puts 'loading answers_options'
    sql = 'SELECT * FROM answers_options'
    ActiveRecord::Base.connection.exec_query(sql).map do |answers_option|
      answers_option = answers_option.with_indifferent_access
      answers_options << answers_option
    end
    file_name = 'db/seeds/staging/temp/answers_options.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(answers_options))
    # answers_question_options
    answers_question_options = []
    puts 'loading answers_question_options'
    sql = 'SELECT * FROM answers_question_options'
    ActiveRecord::Base.connection.exec_query(sql).map do |answers_question_option|
      answers_question_option = answers_question_option.with_indifferent_access
      answers_question_options << answers_question_option
    end
    file_name = 'db/seeds/staging/temp/answers_question_options.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(answers_question_options))
    # suggested_answers
    suggested_answers = []
    puts 'loading suggested_answers'
    sql = 'SELECT * FROM suggested_answers'
    ActiveRecord::Base.connection.exec_query(sql).map do |suggested_answer|
      suggested_answer = suggested_answer.with_indifferent_access
      suggested_answers << suggested_answer
    end
    file_name = 'db/seeds/staging/temp/suggested_answers.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(suggested_answers))
    # versions & versions_translations
    versions = []
    puts 'loading versions'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM versions'
    ActiveRecord::Base.connection.exec_query(sql).map do |version|
      version = version.with_indifferent_access
      timestamps.each { |ek| version[ek.to_sym] = version[ek.to_sym].to_s }
      versions << version
    end
    file_name = 'db/seeds/staging/temp/versions.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(versions))
    version_translations = []
    puts 'loading version_translations'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM version_translations'
    ActiveRecord::Base.connection.exec_query(sql).map do |version_translation|
      version_translation = version_translation.with_indifferent_access
      timestamps.each { |ek| version_translation[ek.to_sym] = version_translation[ek.to_sym].to_s }
      version_translations << version_translation
    end
    file_name = 'db/seeds/staging/temp/version_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(version_translations))
  end
  # projects and file related
  task read6: :environment do
    # friendly_id_slugs
    timestamps = ['created_at']
    friendly_id_slugs = []
    puts 'loading friendly_id_slugs'
    sql = 'SELECT * FROM friendly_id_slugs'
    ActiveRecord::Base.connection.exec_query(sql).map do |friendly_id_slug|
      friendly_id_slug = friendly_id_slug.with_indifferent_access
      timestamps.each { |ek| friendly_id_slug[ek.to_sym] = friendly_id_slug[ek.to_sym].to_s }
      friendly_id_slugs << friendly_id_slug
    end
    file_name = 'db/seeds/staging/temp/friendly_id_slugs.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(friendly_id_slugs))
    # projects
    projects = []
    puts 'loading projects'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM projects'
    ActiveRecord::Base.connection.exec_query(sql).map do |project|
      project = project.with_indifferent_access
      timestamps.each { |ek| project[ek.to_sym] = project[ek.to_sym].to_s }
      projects << project
    end
    file_name = 'db/seeds/staging/temp/projects.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(projects))
    # project_groups
    project_groups = []
    puts 'loading project_groups'
    timestamps = %w[created_at
                    updated_at]
    sql = 'SELECT * FROM project_groups'
    ActiveRecord::Base.connection.exec_query(sql).map do |project_group|
      project_group = project_group.with_indifferent_access
      timestamps.each { |ek| project_group[ek.to_sym] = project_group[ek.to_sym].to_s }
      project_groups << project_group
    end
    file_name = 'db/seeds/staging/temp/project_groups.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(project_groups))
    # project_guidance
    project_guidances = []
    puts 'loading project_guidance'
    sql = 'SELECT * FROM project_guidance'
    ActiveRecord::Base.connection.exec_query(sql).map do |project_guidance|
      project_guidance = project_guidance.with_indifferent_access
      project_guidances << project_guidance
    end
    file_name = 'db/seeds/staging/temp/project_guidances.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(project_guidances))
    # file_types & file_uploads has no data, skipped
    # exported_plans
    exported_plans = []
    puts 'loading exported_plans'
    sql = 'SELECT * FROM exported_plans'
    ActiveRecord::Base.connection.exec_query(sql).map do |exported_plan|
      exported_plan = exported_plan.with_indifferent_access
      timestamps.each { |ek| exported_plan[ek.to_sym] = exported_plan[ek.to_sym].to_s }
      exported_plans << exported_plan
    end
    file_name = 'db/seeds/staging/temp/exported_plans.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(exported_plans))
  end
  # API, setting, sessions and rests
  task read7: :environment do
    timestamps = %w[created_at
                    updated_at]
    # ar_internal_metadata
    ar_internal_metadatas = []
    puts 'loading ar_internal_metadata'
    sql = 'SELECT * FROM ar_internal_metadata'
    ActiveRecord::Base.connection.exec_query(sql).map do |ar_internal_metadata|
      ar_internal_metadata = ar_internal_metadata.with_indifferent_access
      timestamps.each { |ek| ar_internal_metadata[ek.to_sym] = ar_internal_metadata[ek.to_sym].to_s }
      ar_internal_metadatas << ar_internal_metadata
    end
    file_name = 'db/seeds/staging/temp/ar_internal_metadata.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(ar_internal_metadatas))
    # sessions
    sessions = []
    puts 'loading sessions'
    sql = 'SELECT * FROM sessions'
    ActiveRecord::Base.connection.exec_query(sql).map do |session|
      session = session.with_indifferent_access
      timestamps.each { |ek| session[ek.to_sym] = session[ek.to_sym].to_s }
      sessions << session
    end
    file_name = 'db/seeds/staging/temp/sessions.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(sessions))
    # settings
    settings = []
    puts 'loading settings'
    sql = 'SELECT * FROM settings'
    ActiveRecord::Base.connection.exec_query(sql).map do |setting|
      setting = setting.with_indifferent_access
      timestamps.each { |ek| setting[ek.to_sym] = setting[ek.to_sym].to_s }
      settings << setting
    end
    file_name = 'db/seeds/staging/temp/settings.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(settings))
    # stats
    stats = []
    puts 'loading stats'
    sql = 'SELECT * FROM stats'
    ActiveRecord::Base.connection.exec_query(sql).map do |stat|
      stat = stat.with_indifferent_access
      timestamps.each { |ek| stat[ek.to_sym] = stat[ek.to_sym].to_s }
      stats << stat
    end
    file_name = 'db/seeds/staging/temp/stats.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(stats))
    # splash_logs -> no data, skip
    # stylesheets
    stylesheets = []
    puts 'loading stylesheets'
    sql = 'SELECT * FROM stylesheets'
    ActiveRecord::Base.connection.exec_query(sql).map do |stylesheet|
      stylesheet = stylesheet.with_indifferent_access
      timestamps.each { |ek| stylesheet[ek.to_sym] = stylesheet[ek.to_sym].to_s }
      stylesheets << stylesheet
    end
    file_name = 'db/seeds/staging/temp/stylesheets.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(stylesheets))
    # trackers
    trackers = []
    puts 'loading trackers'
    sql = 'SELECT * FROM trackers'
    ActiveRecord::Base.connection.exec_query(sql).map do |tracker|
      tracker = tracker.with_indifferent_access
      timestamps.each { |ek| tracker[ek.to_sym] = tracker[ek.to_sym].to_s }
      trackers << tracker
    end
    file_name = 'db/seeds/staging/temp/trackers.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(trackers))
    # notes
    timestamps = %w[created_at updated_at]
    notes = []
    puts 'loading notes'
    sql = 'SELECT * FROM notes'
    ActiveRecord::Base.connection.exec_query(sql).map do |note|
      note = note.with_indifferent_access
      timestamps.each { |ek| note[ek.to_sym] = note[ek.to_sym].to_s }
      notes << note
    end
    file_name = 'db/seeds/staging/temp/notes.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(notes))
    # prefs
    prefs = []
    puts 'loading prefs'
    sql = 'SELECT * FROM prefs'
    ActiveRecord::Base.connection.exec_query(sql).map do |pref|
      pref = pref.with_indifferent_access
      prefs << pref
    end
    file_name = 'db/seeds/staging/temp/prefs.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(prefs))
    # dmptemplates
    dmptemplates = []
    puts 'loading dmptemplates'
    sql = 'SELECT * FROM dmptemplates'
    ActiveRecord::Base.connection.exec_query(sql).map do |dmptemplate|
      dmptemplate = dmptemplate.with_indifferent_access
      timestamps.each { |ek| dmptemplate[ek.to_sym] = dmptemplate[ek.to_sym].to_s }
      dmptemplates << dmptemplate
    end
    file_name = 'db/seeds/staging/temp/dmptemplates.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(dmptemplates))
    # dmptemplate_translations
    dmptemplate_translations = []
    puts 'loading dmptemplate_translations'
    sql = 'SELECT * FROM dmptemplate_translations'
    ActiveRecord::Base.connection.exec_query(sql).map do |dmptemplate_translation|
      dmptemplate_translation = dmptemplate_translation.with_indifferent_access
      timestamps.each { |ek| dmptemplate_translation[ek.to_sym] = dmptemplate_translation[ek.to_sym].to_s }
      dmptemplate_translations << dmptemplate_translation
    end
    file_name = 'db/seeds/staging/temp/dmptemplate_translations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(dmptemplate_translations))
    # dmptemplates_guidance_groups
    dmptemplates_guidance_groups = []
    puts 'loading dmptemplates_guidance_groups'
    sql = 'SELECT * FROM dmptemplates_guidance_groups'
    ActiveRecord::Base.connection.exec_query(sql).map do |dmptemplates_guidance_group|
      dmptemplates_guidance_group = dmptemplates_guidance_group.with_indifferent_access
      dmptemplates_guidance_groups << dmptemplates_guidance_group
    end
    file_name = 'db/seeds/staging/temp/dmptemplates_guidance_groups.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(dmptemplates_guidance_groups))
    # region_groups - skip no data
    # schema_migrations
    schema_migrations = []
    puts 'loading schema_migrations'
    sql = 'SELECT * FROM schema_migrations'
    ActiveRecord::Base.connection.exec_query(sql).map do |schema_migration|
      schema_migration = schema_migration.with_indifferent_access
      schema_migrations << schema_migration
    end
    file_name = 'db/seeds/staging/temp/schema_migrations.rb'
    FileUtils.rm_f(file_name)
    File.write(file_name, JSON.dump(schema_migrations))
  end
end
