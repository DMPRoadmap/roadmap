require 'json'
namespace :rewrite_postgres do
    desc "Rewrite PostgresSQL tables original MySQL Data using raw query. Please make sure you have switched to PostgreSQL database."
    task retrieve_data: :environment do
        ActiveRecord::Base.establish_connection("#{Rails.env}".to_sym) 
        Rake::Task['rewrite_postgres:users'].execute
        Rake::Task['rewrite_postgres:notifications'].execute
        Rake::Task['rewrite_postgres:notification_acknowledgements'].execute
        puts "Now, please test user login THEN DELETE /db/seeds/staging/temp folder for security."    
    end
    task users: :environment do
        users = JSON.parse(File.read("db/seeds/staging/temp/users.rb"))
        users.each { |x| 
            puts "writing back user #{x['id']}" 
            active = x['active']==0? false:true
            accept_terms = x['accept_terms']==0? false:true
            query = ActiveRecord::Base.sanitize_sql(['INSERT INTO users VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
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
                x['last_api_access']
                ])
            ActiveRecord::Base.connection.exec_query(query)
        }
    end
    # task encrypted_passwords: :environment do
    #     users = JSON.parse(File.read("db/seeds/staging/temp/encrypted_passwords.rb"))
    #     users.each { |x| 
    #         puts "writing back user #{x['id']}" 
    #         query = ActiveRecord::Base.sanitize_sql(['UPDATE users SET encrypted_password = ? WHERE id= ?', x['encrypted_password'],x['id']])
    #         ActiveRecord::Base.connection.exec_query(query)
    #     }
    # end
    task notifications: :environment do
        notifications = JSON.parse(File.read("db/seeds/staging/temp/notifications.rb"))
        notifications.each { |x| 
            dismissable = x['dismissable']==0? false:true
            enabled = x['enabled']==0? false:true
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
                enabled
                ])
            ActiveRecord::Base.connection.exec_query(query)
        }
    end
    task notification_acknowledgements: :environment do
        n_as = JSON.parse(File.read("db/seeds/staging/temp/notification_acknowledgements.rb"))
        n_as.each { |x| 
            query = ActiveRecord::Base.sanitize_sql(['INSERT INTO notification_acknowledgements VALUES (?, ?, ?, ?, ?)', 
                x['id'],
                x['user_id'],
                x['notification_id'],
                x['created_at'],
                x['updated_at']
                ])
            ActiveRecord::Base.connection.exec_query(query)
        }
    end
end
