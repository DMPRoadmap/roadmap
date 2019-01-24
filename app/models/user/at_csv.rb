class User
  class AtCsv

    HEADERS = ['Name', 'E-Mail', 'Created Date', 'Last Activity', 'Plans', 'Current Privileges',  'Active']

    def initialize(users)
      @users = users
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        @users.each do |user|
          name = "#{user.firstname} #{user.surname}"
          email = user.email
          created = I18n.l user.created_at.to_date, format: :csv
          last_activity = I18n.l user.updated_at.to_date, format: :csv
          plans = user.plans.size
          active = user.active ? 'Yes' : 'No'

          if user.can_super_admin?
            current_privileges = 'Super Admin'
          elsif  user.can_org_admin?
            current_privileges = 'Organisational Admin'
          else
            current_privileges = ''
          end

          csv << [ name, email, created, last_activity, plans, current_privileges,  active ]
        end
      end
    end

  end
end