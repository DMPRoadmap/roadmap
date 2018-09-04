require_relative '../../app/actions/stat_created_plan/generate'
require_relative '../../app/actions/stat_joined_user/generate'

namespace :stat do
  namespace :created_plan do
    namespace :generate do
      desc "Generate created plan stats for every org since they joined"
      task full_all_orgs: :environment do
        Actions::StatCreatedPlan::Generate.full_all_orgs
      end

      desc "Generate created plan stats for today's last month for every org"
      task last_month_all_orgs: :environment do
        Actions::StatCreatedPlan::Generate.last_month_all_orgs
      end
    end
  end
  
  namespace :joined_user do
    namespace :generate do
      desc "Generate joined user stats for every org since they joined"
      task full_all_orgs: :environment do
        Actions::StatJoinedUser::Generate.full_all_orgs
      end

      desc "Generate joined user stats for today's last month for every org"
      task last_month_all_orgs: :environment do
        Actions::StatJoinedUser::Generate.last_month_all_orgs
      end
    end
  end
end
