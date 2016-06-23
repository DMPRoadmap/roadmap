class TokenPermission < ActiveRecord::Base
  attr_accessible :token_permission_type_id, :token_permission_type,  :api_token, :user_id, :user, :as => [:default, :admin]

  #associations between tables
  belongs_to :token_permission_type
  belongs_to :user



end
