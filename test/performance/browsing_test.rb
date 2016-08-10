require 'test_helper'

# The performance test helper is no longer a part of Rails 4.x. 
# Just add the gem to the gemfile if you want use it in the future
=begin
require 'rails/performance_test_help'

class BrowsingTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def test_homepage
    get '/'
  end
end
=end