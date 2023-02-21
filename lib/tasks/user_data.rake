# frozen_string_literal: true

namespace :db do
  desc 'Fill database with sample data'
  task populate: :environments do
    admin = User.create!(email: 'test@test.com',
                         password: 'password',
                         password_confirmation: 'password')
    admin.add_role(:admin)
  end

  def log_deleted_user(index, user_total, user_email = nil)
    user_total_string_length = user_total.to_s.length
    message = "#{index.to_s.rjust(user_total_string_length, ' ')}/#{user_total}"
    message += " : #{user_email}" unless user_email.nil?
    puts message
  end

  desc 'Delete potential spam accounts'
  task delete_potential_spam_accounts: :environment do
    puts 'Starting deleting users with potential spam accounts'
    Rake::Task['db:delete_year_old_accounts_with_no_activity'].execute
    Rake::Task['db:delete_users_with_http_in_name'].execute
    Rake::Task['db:delete_users_100_characters'].execute
    Rake::Task['db:delete_users_no_email_mx'].execute
    puts 'Done!'
  end

  desc 'Delete year old accounts with no activity'
  task delete_year_old_accounts_with_no_activity: :environment do
    # Users that have not signed in
    users = User.where(last_sign_in_at: nil).entries

    puts 'Starting deleting year old accounts with no activity'
    log_deleted_user(0, users.count)
    users.each_with_index do |user, index|
      # And users created more than a year ago
      next unless (Time.now - user.created_at) / (24 * 60 * 60 * 365) > 1

      begin
        user.destroy
        log_deleted_user(index + 1, users.count, user[:email])
      rescue StandardError
        puts "Problem deleting user #{user[:email]}"
      end
    end
    puts 'Done!'
  end

  desc 'Delete user accounts with http in its name'
  task delete_users_with_http_in_name: :environment do
    users = User.all.select { |x| x.firstname.include?('http') || x.surname.include?('http') }
    puts 'Starting deleting users with http in its name'
    log_deleted_user(0, users.count)
    users.each_with_index do |user, index|
      user.destroy
      log_deleted_user(index + 1, users.count, user[:email])
    rescue StandardError
      puts "Problem deleting user #{user[:email]}"
    end
    puts 'Done!'
  end

  desc 'Delete user with firstname surname with 100 characters'
  task delete_users_100_characters: :environment do
    users = User.all.select { |x| x.firstname.length > 100 || x.surname.length > 100 }
    puts 'Starting deleting users with firstnames and surnames longer than 100 characters'
    log_deleted_user(0, users.count)
    users.each_with_index do |user, index|
      user.destroy
      log_deleted_user(index + 1, users.count, user[:email])
    rescue StandardError
      puts "Problem deleting user #{user[:email]}"
    end
    puts 'Done!'
  end

  desc 'Delete User entries with emails with no MX DNS record'
  task delete_users_no_email_mx: :environment do
    Truemail.configure do |config|
      config.verifier_email = 'validate@portagenetwork.ca'
    end

    user_total = User.count

    puts 'Starting deleting users with no MX DNS record'
    log_deleted_user(0, user_total)
    User.all.entries.each_with_index do |user, idx|
      email_validator = Truemail.validate(user[:email], with: :mx)
      next if email_validator.result.success # do

      begin
        log_deleted_user(idx + 1, user_total, user[:email])
        user.destroy
      rescue StandardError
        puts "Problem deleting user #{user[:email]}"
      end
    end
    puts 'Done!'
  end
end
