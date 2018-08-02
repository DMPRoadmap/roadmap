# == Schema Information
#
# Table name: splash_logs
#
#  id          :integer          not null, primary key
#  destination :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SplashLog < ActiveRecord::Base
end
