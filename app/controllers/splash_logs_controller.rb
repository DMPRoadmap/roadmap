class SplashLogsController < ApplicationController
  respond_to :html

  ##
	# POST /answers
	def create
		@splash_log = SplashLog.new()
		@splash_log.destination = params[:destination]
		if @splash_log.save
			cookies[:dmp_splash_seen] = {
				value: 'splash_dialog_seen',
				expires: 3.hours.from_now,
			}
			redirect_to params[:destination]
		else
			redirect_to home_url
		end
	end
end