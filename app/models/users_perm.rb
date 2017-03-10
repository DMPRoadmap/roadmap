class UsersPerm < ActiveRecord::Base
  has_many :user
  has_many :perm
end