class UserIdentifier < ActiveRecord::Base
  belongs_to :user
  belongs_to :identifier_scheme
end