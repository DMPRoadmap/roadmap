# frozen_string_literal: true

# Helper for Admins
class User
  # Helper to export a list of Users as CSV
  class AtCsv
    HEADERS = [_('Name'), _('E-Mail'), _('Created Date'), _('Last Activity'), _('Plans'),
               _('Current Privileges'), _('Active'), _('Department')].freeze

    def initialize(users)
      @users = users.includes(:plans, :department, :perms)
      @super_admin_perm = Perm.add_orgs
      @org_admin_perm = Perm.modify_templates
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        @users.each do |user|
          name = "#{user.firstname} #{user.surname}"
          email = user.email
          created = I18n.l user.created_at.localtime.to_date, format: :csv
          last_activity = I18n.l user.updated_at.localtime.to_date, format: :csv
          plans = user.plans.length
          active = user.active ? 'Yes' : 'No'

          current_privileges = if user.perms.include?(@super_admin_perm)
                                 'Super Admin'
                               elsif user.perms.include?(@org_admin_perm)
                                 'Organisational Admin'
                               else
                                 ''
                               end

          department = user&.department&.name || ''

          csv << [name, email, created, last_activity, plans, current_privileges,
                  active, department]
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
