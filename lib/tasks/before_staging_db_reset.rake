# frozen_string_literal: true

require 'json'
namespace :before_seeds do
  desc 'Run this task before rake db:seed'
  task copy_data: :environment do
    ActiveRecord::Base.establish_connection(Rails.env.to_s.to_sym)
    Rake::Task['before_seeds:themes'].execute
    Rake::Task['before_seeds:guidance_group'].execute
    Rake::Task['before_seeds:guidances'].execute
    Rake::Task['before_seeds:themes_in_guidance'].execute
    Rake::Task['before_seeds:guidance_in_group'].execute
    Rake::Task['before_seeds:guidance_translations'].execute
    puts 'Now, run bin/rails db:seed'
  end
  task themes: :environment do
    tg = JSON.parse(File.read('db/seeds/staging/temp/themes.rb'))
    tg.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO themes VALUES (?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['title'],
                                               x['description'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['locale']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task guidance_group: :environment do
    t_i_g = JSON.parse(File.read('db/seeds/staging/temp/guidance_groups.rb'))
    t_i_g.each do |x|
      published = x['published'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO guidance_groups VALUES (?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['text'],
                                               x['guidance_group_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               published])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task themes_in_guidance: :environment do
    t_i_g = JSON.parse(File.read('db/seeds/staging/temp/themes_in_guidance.rb'))
    t_i_g.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO themes_in_guidance VALUES (?, ?)',
                                               x['theme_id'],
                                               x['guidance_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task guidances: :environment do
    t_i_g = JSON.parse(File.read('db/seeds/staging/temp/guidances.rb'))
    t_i_g.each do |x|
      published = x['published'] != 0
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO guidances VALUES (?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['text'],
                                               x['guidance_group_id'],
                                               x['created_at'],
                                               x['updated_at'],
                                               published])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task guidance_in_group: :environment do
    t_i_g = JSON.parse(File.read('db/seeds/staging/temp/guidance_in_group.rb'))
    t_i_g.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO guidance_in_group VALUES (?, ?)',
                                               x['guidance_id'],
                                               x['guidance_group_id']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
  task guidance_translations: :environment do
    t_i_g = JSON.parse(File.read('db/seeds/staging/temp/guidance_translations.rb'))
    t_i_g.each do |x|
      query = ActiveRecord::Base.sanitize_sql(['INSERT INTO guidance_translations VALUES (?, ?, ?, ?, ?, ?)',
                                               x['id'],
                                               x['guidance_id'],
                                               x['locale'],
                                               x['created_at'],
                                               x['updated_at'],
                                               x['text']])
      ActiveRecord::Base.connection.exec_query(query)
    end
  end
end
