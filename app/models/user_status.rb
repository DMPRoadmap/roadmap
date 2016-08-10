class UserStatus < ActiveRecord::Base
  attr_accessible :description, :name, :as => [:default, :admin]

  #associations between tables
  has_many :users
end
