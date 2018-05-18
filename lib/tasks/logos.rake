namespace :logos do
  desc "Resize all of the logos based on the settings in `models/org.rb`"
  task resize_all: :environment do
    Org.all.each do |org|
      if org.logo.present?
        img = org.logo
        org.logo = img
        org.save!
      end
    end
  end
end