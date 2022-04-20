<<<<<<< HEAD
namespace :stat do

  desc "Build all stats"
=======
# frozen_string_literal: true

namespace :stat do
  desc 'Build all stats'
>>>>>>> upstream/master
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
<<<<<<< HEAD
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
=======
    tasks = ['stat:create:created_plan',
             'stat:create:joined_user',
             'stat:create:shared_plan',
             'stat:create:exported_plan',
             'stat:create_last_month:created_plan',
             'stat:create_last_month:joined_user',
             'stat:create_last_month:shared_plan',
             'stat:create_last_month:exported_plan']

    Parallel.each(tasks, progress: 'Building Stats', in_processes: 4) do |tsk|
      Rake::Task[tsk].execute
    end
  end

  task build_last_month: :environment do
    tasks = ['stat:create_last_month:created_plan',
             'stat:create_last_month:joined_user',
             'stat:create_last_month:shared_plan',
             'stat:create_last_month:exported_plan']

    tasks.each do |tsk|
      Rake::Task[tsk].execute
>>>>>>> upstream/master
    end
  end

  task build_last_month_parallel: :environment do
<<<<<<< HEAD
    tasks = ["stat:create_last_month:created_plan",
             "stat:create_last_month:joined_user",
             "stat:create_last_month:shared_plan",
             "stat:create_last_month:exported_plan"]

    Parallel.each(tasks) do |task|
      Rake::Task[task].execute
=======
    tasks = ['stat:create_last_month:created_plan',
             'stat:create_last_month:joined_user',
             'stat:create_last_month:shared_plan',
             'stat:create_last_month:exported_plan']

    Parallel.each(tasks) do |tsk|
      Rake::Task[tsk].execute
>>>>>>> upstream/master
      task
    end
  end

  namespace :create do
<<<<<<< HEAD
    desc "Creates created plan stats for every org since they joined"
=======
    desc 'Creates created plan stats for every org since they joined'
>>>>>>> upstream/master
    task created_plan: :environment do
      Org::CreateCreatedPlanService.call(threads: 2)
    end

<<<<<<< HEAD
    desc "Creates joined user stats for every org since they joined"
=======
    desc 'Creates joined user stats for every org since they joined'
>>>>>>> upstream/master
    task joined_user: :environment do
      Org::CreateJoinedUserService.call(threads: 2)
    end

<<<<<<< HEAD
    desc "Creates shared plan stats for every org since they joined"
=======
    desc 'Creates shared plan stats for every org since they joined'
>>>>>>> upstream/master
    task shared_plan: :environment do
      Org::CreateSharedPlanService.call(threads: 2)
    end

<<<<<<< HEAD
    desc "Creates exported plan stats for every org since they joined"
    task exported_plan: :environment do
      Org::CreateExportedPlanService.call(threads: 2)
    end

=======
    desc 'Creates exported plan stats for every org since they joined'
    task exported_plan: :environment do
      Org::CreateExportedPlanService.call(threads: 2)
    end
>>>>>>> upstream/master
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
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
