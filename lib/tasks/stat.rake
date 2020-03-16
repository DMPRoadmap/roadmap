namespace :stat do

  desc "Build all stats"
  task build: :environment do
    Rake::Task['stat:create:created_plan'].execute
    Rake::Task['stat:create:joined_user'].execute
    Rake::Task['stat:create:shared_plan'].execute
    Rake::Task['stat:create:exported_plan'].execute
    Rake::Task['stat:create_last_month:created_plan'].execute
    Rake::Task['stat:create_last_month:joined_user'].execute
    Rake::Task['stat:create_last_month:shared_plan'].execute
    Rake::Task['stat:create_last_month:exported_plan'].execute
  end

  task build_parallel: :environment do
    tasks = ["stat:create:created_plan",
             "stat:create:joined_user",
             "stat:create:shared_plan",
             "stat:create:exported_plan",
             "stat:create_last_month:created_plan",
             "stat:create_last_month:joined_user",
             "stat:create_last_month:shared_plan",
             "stat:create_last_month:exported_plan"]

      Parallel.each(tasks, progress: "Building Stats", in_processes: 4) do |task|
        Rake::Task[task].execute
        task
      end
   end

  task build_last_month: :environment do
    tasks = ["stat:create_last_month:created_plan",
             "stat:create_last_month:joined_user",
             "stat:create_last_month:shared_plan",
             "stat:create_last_month:exported_plan"]

    tasks.each do |task|
      Rake::Task[task].execute
    end
  end

  task build_last_month_parallel: :environment do
    tasks = ["stat:create_last_month:created_plan",
             "stat:create_last_month:joined_user",
             "stat:create_last_month:shared_plan",
             "stat:create_last_month:exported_plan"]

    Parallel.each(tasks) do |task|
      Rake::Task[task].execute
      task
    end
  end

  namespace :create do
    desc "Creates created plan stats for every org since they joined"
    task created_plan: :environment do
      Org::CreateCreatedPlanService.call(threads: 2)
    end

    desc "Creates joined user stats for every org since they joined"
    task joined_user: :environment do
      Org::CreateJoinedUserService.call(threads: 2)
    end

    desc "Creates shared plan stats for every org since they joined"
    task shared_plan: :environment do
      Org::CreateSharedPlanService.call(threads: 2)
    end

    desc "Creates exported plan stats for every org since they joined"
    task exported_plan: :environment do
      Org::CreateExportedPlanService.call(threads: 2)
    end

  end

  namespace :create_last_month do
    desc "Creates created plan stats for today's last month for every org"
    task created_plan: :environment do
      Org::CreateLastMonthCreatedPlanService.call(threads: 2)
    end

    desc "Creates joined user stats for today's last month for every org"
    task joined_user: :environment do
      Org::CreateLastMonthJoinedUserService.call(threads: 2)
    end

    desc "Creates shared plan stats for today's last month for every org"
    task shared_plan: :environment do
      Org::CreateLastMonthSharedPlanService.call(threads: 2)
    end

    desc "created exported plan stats for today's last month for every org"
    task exported_plan: :environment do
      Org::CreateLastMonthExportedPlanService.call(threads: 2)
    end
  end

end
