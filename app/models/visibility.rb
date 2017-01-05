class Visibility < ActiveRecord::Base
  has_many :projects
  
  validates :name, uniqueness: true, presence: true
end