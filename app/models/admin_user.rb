class AdminUser < ActiveRecord::Base
	devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
	attr_accessible :email, :password, :password_confirmation, :remember_me
end
