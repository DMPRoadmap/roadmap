namespace :export do
    desc "Build all stats"
    task build_sandbox_data: :environment do
        sh 'rake export:export_portage_1 > db/seeds/seeds_1.rb'
        sh 'rake export:export_portage_2 > db/seeds/seeds_2.rb'
        sh 'rake export:export_portage_3 > db/seeds/seeds_3.rb'
        puts 'Now, switch to sandbox database and run rake db:setup or rake db:reset'
    end
end