# To maintain the original hierarchy, all items below needs to keep the original id

require 'faker'

namespace :export do
  desc "Export org, guidance_group and guidance from 3.0.2 database" 
  task :export_portage_1 => :environment do
    excluded_keys = ['created_at','updated_at'] 
    Org.all.each do |org|
      if org.id == 8 # super admin's org: Portage network in production database
        org.name = Rails.configuration.x.organisation.name
        org.abbreviation = Rails.configuration.x.organisation.abbreviation
        org.created_at = 6.year.ago
        org.region = Region.all.first
        serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
        puts "Org.create(#{serialized})"
      elsif org.id == 7 # tester 1' org
        org.name = "Institution Example Org 1"
        org.abbreviation = "OEO"
        org.created_at = 6.year.ago
        org.region = Region.all.first
        serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
        puts "Org.create(#{serialized})"
      elsif org.id == 1 # tester 2'org
        org.name = "Institution Example Org 2"
        org.abbreviation = "IEO"
        org.created_at = 6.year.ago
        org.region = Region.all.first
        serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
        puts "Org.create(#{serialized})"
      else
        org.region = Region.all.first
        serialized = org.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
        puts "Org.create(#{serialized})"
      end
    end
  end
  desc "Export question formats from 3.0.2 database" 
  task :export_portage_1=> :environment do
    QuestionFormat.all.each do |question_formats| 
      excluded_keys = ['created_at','updated_at'] 
      serialized = question_formats.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
      puts "QuestionFormat.create(#{serialized})"
    end 
  end
end