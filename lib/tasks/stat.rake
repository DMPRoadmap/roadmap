namespace :stat do

  desc "Build all stats"
  task build: :environment do
    Rake::Task['stat:create:created_plan'].execute
    Rake::Task['stat:create:joined_user'].execute
    Rake::Task['stat:create_last_month:created_plan'].execute
    Rake::Task['stat:create_last_month:joined_user'].execute
  end

  namespace :create do
    desc "Creates created plan stats for every org since they joined"
    task created_plan: :environment do
      Org::CreateCreatedPlanService.call
    end

    desc "Creates joined user stats for every org since they joined"
    task joined_user: :environment do
      Org::CreateJoinedUserService.call
    end
  end

  namespace :create_last_month do
    desc "Creates created plan stats for today's last month for every org"
    task created_plan: :environment do
      Org::CreateLastMonthCreatedPlanService.call
    end

    desc "Creates joined user stats for today's last month for every org"
    task joined_user: :environment do
      Org::CreateLastMonthJoinedUserService.call
    end
  end
end
