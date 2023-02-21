# frozen_string_literal: true

require 'json'
namespace :rewrite_postgres do
  desc 'Start the action to write original MySQL Data in PostgreSQL.'
  task retrieve_data: :environment do
    ActiveRecord::Base.establish_connection(Rails.env.to_s.to_sym)
    Rake::Task['rewrite_postgres:users'].execute
    Rake::Task['rewrite_postgres:users_perms_status_types'].execute
    Rake::Task['rewrite_postgres:notifications'].execute
    Rake::Task['rewrite_postgres:notification_acknowledgements'].execute
    Rake::Task['rewrite_postgres:templates'].execute
    Rake::Task['rewrite_postgres:phases_and_translations'].execute
    Rake::Task['rewrite_postgres:sections_and_translations'].execute
    Rake::Task['rewrite_postgres:question_formats_translations'].execute
    Rake::Task['rewrite_postgres:questions_and_translations'].execute
    Rake::Task['rewrite_postgres:question_options_conditions_themes'].execute
    Rake::Task['rewrite_postgres:identifier_schemes'].execute
    Rake::Task['rewrite_postgres:identifiers'].execute
    Rake::Task['rewrite_postgres:plans'].execute
    Rake::Task['rewrite_postgres:plan_sections'].execute
    Rake::Task['rewrite_postgres:roles'].execute
    Rake::Task['rewrite_postgres:plans_guidance_groups'].execute
    Rake::Task['rewrite_postgres:users_roles'].execute
    Rake::Task['rewrite_postgres:contributors'].execute
    Rake::Task['rewrite_postgres:comments'].execute
    Rake::Task['rewrite_postgres:versions'].execute
    Rake::Task['rewrite_postgres:version_translations'].execute
    Rake::Task['rewrite_postgres:exported_plans'].execute
    Rake::Task['rewrite_postgres:annotations_answers_options_suggested_answers'].execute
    Rake::Task['rewrite_postgres:organisations_types_token_permissions'].execute
    # Rake::Task['rewrite_postgres:versions_translations'].execute
    Rake::Task['rewrite_postgres:projects_files'].execute
    Rake::Task['rewrite_postgres:settings_sessions_stats_stylesheets'].execute
    Rake::Task['rewrite_postgres:trackers_notes_prefs_dmptemplates_migrations'].execute
    Rake::Task['rewrite_postgres:reset_all_pk'].execute
    puts 'Now, please test user login THEN DELETE /db/seeds/staging/temp folder for security.'
  end

  task users: :environment do
    users = JSON.parse(File.read('db/seeds/staging/temp/users.rb'))
    users.each do |x|
      puts "writing back user #{x['id']}"
      active = x['active'] != 0
      accept_terms = x['accept_terms'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO users
                                              VALUES
                                              (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['firstname'],
                                               x['surname'],
                                               x['email'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['encrypted_password'],
                                               x['reset_password_token'],
                                               x['reset_password_sent_at'],
                                               x['remember_created_at'],
                                               x['sign_in_count'],
                                               x['current_sign_in_at'],
                                               x['last_sign_in_at'],
                                               x['current_sign_in_ip'],
                                               x['last_sign_in_ip'],
                                               x['confirmation_token'],
                                               x['confirmed_at'],
                                               x['confirmation_sent_at'],
                                               x['invitation_token'],
                                               x['invitation_created_at'],
                                               x['invitation_sent_at'],
                                               x['invitation_accepted_at'],
                                               x['other_organisation'],
                                               x['dmponline3'],
                                               accept_terms,
                                               x['org_id'],
                                               x['api_token'],
                                               x['invited_by_id'],
                                               x['invited_by_type'],
                                               x['language_id'],
                                               x['recovery_email'],
                                               active,
                                               x['department_id'],
                                               x['last_api_access']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task users_perms_status_types: :environment do
    u_p = JSON.parse(File.read('db/seeds/staging/temp/users_perms.rb'))
    u_p.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO users_perms VALUES (?, ?)',
                                               x['user_id'],
                                               x['perm_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    u_s = JSON.parse(File.read('db/seeds/staging/temp/user_statuses.rb'))
    u_s.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO user_statuses VALUES (?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['name'],
                                               x['description'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    u_t = JSON.parse(File.read('db/seeds/staging/temp/user_types.rb'))
    u_t.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO user_types VALUES (?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['name'],
                                               x['description'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task notifications: :environment do
    notifications = JSON.parse(File.read('db/seeds/staging/temp/notifications.rb'))
    notifications.each do |x|
      dismissable = x['dismissable'] != 0
      enabled = x['enabled'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO notifications VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['notification_type'],
                                               x['title'],
                                               x['level'],
                                               x['body'],
                                               dismissable,
                                               x['starts_at'],
                                               x['expires_at'],
                                               x['created_at'],
                                               x['updated_at'],
                                               enabled])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task notification_acknowledgements: :environment do
    n_as = JSON.parse(File.read('db/seeds/staging/temp/notification_acknowledgements.rb'))
    n_as.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO notification_acknowledgements VALUES (?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['user_id'],
                                               x['notification_id'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task templates: :environment do
    t = JSON.parse(File.read('db/seeds/staging/temp/templates.rb'))
    t.each do |x|
      published = x['published'] != 0
      archived = x['archived'] != 0
      is_default = x['is_default'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO templates
                                                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               published,
                                               x['org_id'],
                                               x['locale'],
                                               is_default,
                                               x['created_at'],
                                               x['updated_at'],
                                               x['version'],
                                               x['visibility'],
                                               x['customization_of'],
                                               x['family_id'],
                                               archived,
                                               x['links']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task phases_and_translations: :environment do
    ps = JSON.parse(File.read('db/seeds/staging/temp/phases.rb'))
    ps.each do |x|
      modifiable = x['modifiable'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO phases VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               x['number'],
                                               x['template_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               modifiable,
                                               x['versionable_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    pt = JSON.parse(File.read('db/seeds/staging/temp/phase_translations.rb'))
    pt.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO phase_translations VALUES (?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['phase_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['description']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task sections_and_translations: :environment do
    sec = JSON.parse(File.read('db/seeds/staging/temp/sections.rb'))
    sec.each do |x|
      modifiable = x['modifiable'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO sections VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               x['number'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['phase_id'],
                                               modifiable,
                                               x['versionable_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    st = JSON.parse(File.read('db/seeds/staging/temp/section_translations.rb'))
    st.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO section_translations VALUES (?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['section_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['description']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task question_formats_translations: :environment do
    qft = JSON.parse(File.read('db/seeds/staging/temp/question_format_translations.rb'))
    qft.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO question_format_translations VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['question_format_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['description']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task questions_and_translations: :environment do
    q = JSON.parse(File.read('db/seeds/staging/temp/questions.rb'))
    q.each do |x|
      puts "writing back questions #{x['id']}"
      modifiable = x['modifiable'] != 0
      option_comment_display = x['option_comment_display'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO questions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['text'],
                                               x['default_value'],
                                               x['number'],
                                               x['section_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['question_format_id'],
                                               option_comment_display,
                                               modifiable,
                                               x['versionable_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    qt = JSON.parse(File.read('db/seeds/staging/temp/question_translations.rb'))
    qt.each do |x|
      puts "writing back question translation #{x['id']}"
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO question_translations VALUES (?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['question_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['guidance']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task question_options_conditions_themes: :environment do
    options = JSON.parse(File.read('db/seeds/staging/temp/options.rb'))
    options.each do |x|
      is_default = x['is_default'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO options VALUES (?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['question_id'],
                                               x['text'],
                                               x['number'],
                                               is_default,
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    qo = JSON.parse(File.read('db/seeds/staging/temp/question_options.rb'))
    qo.each do |x|
      is_default = x['is_default'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO question_options VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['question_id'],
                                               x['text'],
                                               x['number'],
                                               is_default,
                                               x['created_at'],
                                               x['updated_at'],
                                               x['versionable_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    qt = JSON.parse(File.read('db/seeds/staging/temp/questions_themes.rb'))
    qt.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO questions_themes VALUES (?,?)',
                                               x['question_id'],
                                               x['theme_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    co = JSON.parse(File.read('db/seeds/staging/temp/conditions.rb'))
    co.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO conditions VALUES (?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['question_id'],
                                               x['option_list'],
                                               x['action_type'],
                                               x['number'],
                                               x['remove_data'],
                                               x['webhook_data'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task identifier_schemes: :environment do
    identifier_schemes = JSON.parse(File.read('db/seeds/staging/temp/identifier_schemes.rb'))
    identifier_schemes.each do |x|
      active = x['active'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO identifier_schemes VALUES (?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['name'],
                                               x['description'],
                                               active,
                                               x['created_at'] == '' ? nil : x['created_at'],
                                               x['updated_at'] == '' ? nil : x['updated_at'],
                                               x['logo_url'],
                                               x['identifier_prefix'],
                                               x['context']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task identifiers: :environment do
    identifiers = JSON.parse(File.read('db/seeds/staging/temp/identifiers.rb'))
    identifiers.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO identifiers VALUES (?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['value'],
                                               x['attrs'],
                                               x['identifier_scheme_id'],
                                               x['identifiable_id'],
                                               x['identifiable_type'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task plans: :environment do
    plans = JSON.parse(File.read('db/seeds/staging/temp/plans.rb'))
    plans.each do |x|
      puts "writing back plan #{x['id']}"
      feedback_requested = x['feedback_requested'] != 0
      complete = x['complete'] != 0
      ethical_issues = x['ethical_issues'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO plans VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['title'],
                                               x['template_id'],
                                               x['created_at'] == '' ? nil : x['created_at'],
                                               x['updated_at'] == '' ? nil : x['updated_at'],
                                               x['identifier'],
                                               x['description'],
                                               x['visibility'],
                                               feedback_requested,
                                               complete,
                                               x['org_id'],
                                               x['funder_id'],
                                               x['grant_id'],
                                               x['start_date'] == '' ? nil : x['start_date'],
                                               x['end_date'] == '' ? nil : x['end_date'],
                                               x['research_domain_id'],
                                               ethical_issues,
                                               x['ethical_issues_description'],
                                               x['ethical_issues_report'],
                                               x['funding status']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task plan_sections: :environment do
    plan_sections = JSON.parse(File.read('db/seeds/staging/temp/plan_sections.rb'))
    plan_sections.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO plan_sections VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['user_id'],
                                               x['section_id'],
                                               x['plan_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['release_time']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task roles: :environment do
    roles = JSON.parse(File.read('db/seeds/staging/temp/roles.rb'))
    roles.each do |x|
      puts "writing back role #{x['id']}"
      active = x['active'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO roles VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['user_id'],
                                               x['plan_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['access'],
                                               active])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task plans_guidance_groups: :environment do
    plans_guidance_groups = JSON.parse(File.read('db/seeds/staging/temp/plans_guidance_groups.rb'))
    plans_guidance_groups.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO plans_guidance_groups VALUES (?,?,?)',
                                               x['id'],
                                               x['guidance_group_id'],
                                               x['plan_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task users_roles: :environment do
    users_roles = JSON.parse(File.read('db/seeds/staging/temp/users_roles.rb'))
    users_roles.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO users_roles VALUES (?,?)',
                                               x['user_id'],
                                               x['role_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task contributors: :environment do
    contributors = JSON.parse(File.read('db/seeds/staging/temp/contributors.rb'))
    contributors.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO contributors VALUES (?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['name'],
                                               x['email'],
                                               x['phone'],
                                               x['roles'],
                                               x['org_id'],
                                               x['plan_id'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task comments: :environment do
    comments = JSON.parse(File.read('db/seeds/staging/temp/comments.rb'))
    comments.each do |x|
      archived = x['archived'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO comments VALUES (?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['user_id'],
                                               x['question_id'],
                                               x['text'],
                                               x['created_at'],
                                               x['updated_at'],
                                               archived,
                                               x['plan_id'],
                                               x['archived_by']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task versions: :environment do
    versions = JSON.parse(File.read('db/seeds/staging/temp/versions.rb'))
    versions.each do |x|
      published = x['published'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO versions VALUES (?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               published,
                                               x['number'],
                                               x['phase_id'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task version_translations: :environment do
    version_translations = JSON.parse(File.read('db/seeds/staging/temp/version_translations.rb'))
    version_translations.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO version_translations VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['version_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['description']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task exported_plans: :environment do
    exported_plans = JSON.parse(File.read('db/seeds/staging/temp/exported_plans.rb'))
    exported_plans.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO exported_plans VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['plan_id'],
                                               x['user_id'],
                                               x['format'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['phase_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task annotations_answers_options_suggested_answers: :environment do
    annotations = JSON.parse(File.read('db/seeds/staging/temp/annotations.rb'))
    annotations.each do |x|
      puts "writing back annotation #{x['id']}"
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO annotations VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['question_id'],
                                               x['org_id'],
                                               x['text'],
                                               x['type'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['versionable_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    answers = JSON.parse(File.read('db/seeds/staging/temp/answers.rb'))
    answers.each do |x|
      puts "writing back answer #{x['id']}"
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO answers VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['text'],
                                               x['plan_id'],
                                               x['user_id'],
                                               x['question_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['lock-version']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    answers_options = JSON.parse(File.read('db/seeds/staging/temp/answers_options.rb'))
    answers_options.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO answers_options VALUES (?, ?)',
                                               x['answer_id'],
                                               x['option_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    answers_question_options = JSON.parse(File.read('db/seeds/staging/temp/answers_question_options.rb'))
    answers_question_options.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO answers_question_options VALUES (?, ?)',
                                               x['answer_id'],
                                               x['question_option_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    suggested_answers = JSON.parse(File.read('db/seeds/staging/temp/suggested_answers.rb'))
    suggested_answers.each do |x|
      is_example = x['is_example'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO suggested_answers VALUES (?, ?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['question_id'],
                                               x['orgnisation_id'],
                                               x['text'],
                                               x['created_at'],
                                               x['updated_at'],
                                               is_example])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  # Rake::Task['rewrite_postgres:organisations_types_token_permissions'].execute
  task organisations_types_token_permissions: :environment do
    # organisations
    organisations = JSON.parse(File.read('db/seeds/staging/temp/organisations.rb'))
    organisations.each do |x|
      is_other = x['is_other'] != 0
      display_in_registration = x['display_in_registration'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO organisations
                                              VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['name'],
                                               x['abbreviation'],
                                               x['target_url'],
                                               x['organisation_type_id'],
                                               x['domain'],
                                               x['wayfless_entity'],
                                               x['stylesheet_file_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['parent_id'],
                                               is_other,
                                               x['sort_name'],
                                               x['banner_text'],
                                               x['logo_file_name'],
                                               display_in_registration,
                                               x['logo_uid'],
                                               x['logo_name'],
                                               x['banner_uid'],
                                               x['banner_name'],
                                               x['region_id'],
                                               x['language_id'],
                                               x['contact_email']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # organisation_types
    organisation_types = JSON.parse(File.read('db/seeds/staging/temp/organisation_types.rb'))
    organisation_types.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO organisation_types VALUES (?,?,?,?,?)',
                                               x['id'],
                                               x['name'],
                                               x['description'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # # org_token_permissions
    # org_token_permissions = JSON.parse(File.read("db/seeds/staging/temp/org_token_permissions.rb"))
    # org_token_permissions.each { |x|
    #     p x['id']
    #     unless x['created_at'].present? # for nil created/updated date
    #         x['created_at'] = nil
    #     end
    #     unless x['updated_at'].present?
    #         x['updated_at'] = nil
    #     end
    #     query = ActiveRecord::Base.sanitize_sql(['INSERT INTO org_token_permissions VALUES (?, ?, ?, ?, ?)',
    #         x['id'],
    #         x['org_id'],
    #         x['token_permission_type_id'],
    #         x['created_at'],
    #         x['updated_at']
    #         ])
    #     ActiveRecord::Base.connection.exec_query(query)
    # }
  end
  # Rake::Task['rewrite_postgres:versions_translations'].execute
  task versions_translations: :environment do
    # versions
    versions = JSON.parse(File.read('db/seeds/staging/temp/versions.rb'))
    versions.each do |x|
      published = x['published'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO versions VALUES (?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               published,
                                               x['number'],
                                               x['phase_id'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # versions_translations
    versions_translations = JSON.parse(File.read('db/seeds/staging/temp/versions_translations.rb'))
    versions_translations.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO versions_translations VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['version_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['description']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  # Rake::Task['rewrite_postgres:projects_files'].execute
  task projects_files: :environment do
    # friendly_id_slugs
    friendly_id_slugs = JSON.parse(File.read('db/seeds/staging/temp/friendly_id_slugs.rb'))
    friendly_id_slugs.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO friendly_id_slugs VALUES (?,?,?,?,?)',
                                               x['id'],
                                               x['slug'],
                                               x['sluggable_id'],
                                               x['sluggable_type'],
                                               x['created_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # projects
    projects = JSON.parse(File.read('db/seeds/staging/temp/projects.rb'))
    projects.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO projects VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['title'],
                                               x['dmptemplate_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['slug'],
                                               x['organisation_id'],
                                               x['grant_number'],
                                               x['identifier'],
                                               x['description'],
                                               x['principal_investigator'],
                                               x['principal_investigator_identifier'],
                                               x['data_contact'],
                                               x['funder_name']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # project_groups
    project_groups = JSON.parse(File.read('db/seeds/staging/temp/project_groups.rb'))
    project_groups.each do |x|
      project_creator = x['project_creator'] != 0
      project_editor = x['project_editor'] != 0
      project_administrator = x['project_administrator'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO project_groups VALUES (?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               project_creator,
                                               project_editor,
                                               x['user_id'],
                                               x['project_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               project_administrator])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # project_guidance
    project_guidances = JSON.parse(File.read('db/seeds/staging/temp/project_guidances.rb'))
    project_guidances.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO project_guidance VALUES (?,?)',
                                               x['project_id'],
                                               x['guidance_group_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # files skipped because no data
  end
  task settings_sessions_stats_stylesheets: :environment do
    # api_clients has no data
    # # ar_internal_metadata
    # ar_internal_metadata = JSON.parse(File.read("db/seeds/staging/temp/ar_internal_metadata.rb"))
    # ar_internal_metadata.each { |x|
    #     query = ActiveRecord::Base.sanitize_sql(['INSERT INTO ar_internal_metadata VALUES (?,?,?,?)',
    #         x['key'],
    #         x['value'],
    #         x['created_at'],
    #         x['updated_at']
    #         ])
    #     ActiveRecord::Base.connection.exec_query(query)
    # }
    # sessions
    sessions = JSON.parse(File.read('db/seeds/staging/temp/sessions.rb'))
    sessions.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO sessions VALUES (?,?,?,?,?)',
                                               x['id'],
                                               x['session_id'],
                                               x['data'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # settings
    settings = JSON.parse(File.read('db/seeds/staging/temp/settings.rb'))
    settings.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO settings VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['var'],
                                               x['value'],
                                               x['target_id'],
                                               x['target_type'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # stats
    stats = JSON.parse(File.read('db/seeds/staging/temp/stats.rb'))
    stats.each do |x|
      filtered = x['filtered'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO stats VALUES (?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['count'],
                                               x['date'],
                                               x['type'],
                                               x['org_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['details'],
                                               filtered])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # stylesheets
    stylesheets = JSON.parse(File.read('db/seeds/staging/temp/stylesheets.rb'))
    stylesheets.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO stylesheets VALUES (?,?,?,?,?,?)',
                                               x['id'],
                                               x['file_uid'],
                                               x['file_name'],
                                               x['organisation_id'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  # Rake::Task['rewrite_postgres:trackers_notes_prefs_dmptemplates_migrations'].execute
  task trackers_notes_prefs_dmptemplates_migrations: :environment do
    # trackers
    trackers = JSON.parse(File.read('db/seeds/staging/temp/trackers.rb'))
    trackers.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO trackers VALUES (?,?,?,?,?)',
                                               x['id'],
                                               x['org_id'],
                                               x['code'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # notes
    notes = JSON.parse(File.read('db/seeds/staging/temp/notes.rb'))
    notes.each do |x|
      archived = x['archived'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO notes VALUES (?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['user_id'],
                                               x['text'],
                                               archived,
                                               x['answer_id'],
                                               x['archived_by'],
                                               x['created_at'],
                                               x['updated_at']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # prefs
    prefs = JSON.parse(File.read('db/seeds/staging/temp/prefs.rb'))
    prefs.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO prefs VALUES (?,?,?)',
                                               x['id'],
                                               x['settings'],
                                               x['user_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # dmptemplates
    dmptemplates = JSON.parse(File.read('db/seeds/staging/temp/dmptemplates.rb'))
    dmptemplates.each do |x|
      published = x['published'] != 0
      is_default = x['is_default'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO dmptemplates VALUES (?,?,?,?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               published,
                                               x['user_id'],
                                               x['organisation_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['locale'],
                                               is_default])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # dmptemplate_translations
    dmptemplate_translations = JSON.parse(File.read('db/seeds/staging/temp/dmptemplate_translations.rb'))
    dmptemplate_translations.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO dmptemplate_translations VALUES (?,?,?,?,?,?,?)',
                                               x['id'],
                                               x['dmptemplate_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['title'],
                                               x['description']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # dmptemplates_guidance_groups
    dmptemplates_guidance_groups = JSON.parse(File.read('db/seeds/staging/temp/dmptemplates_guidance_groups.rb'))
    dmptemplates_guidance_groups.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO dmptemplates_guidance_groups VALUES (?,?)',
                                               x['dmptemplate_id'],
                                               x['guidance_group_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
    # # schema_migrations
    # schema_migrations = JSON.parse(File.read("db/seeds/staging/temp/schema_migrations.rb"))
    # p schema_migrations
    # schema_migrations.each { |x,index|
    #     p x['version']
    #     p index
    #     query = ActiveRecord::Base.sanitize_sql(['INSERT INTO schema_migrations VALUES (?)',
    #         x['version']
    #         ])
    #     ActiveRecord::Base.connection.exec_query(query)
    # }
  end
  task reset_all_pk: :environment do
    puts 'Now reset all primary keys to the max ID...'
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
