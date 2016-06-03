class SplashLogsController < ApplicationController

	# POST /answers
	# POST /answers.json
	def create
		@splash_log = SplashLog.new()
		@splash_log.destination = params[:destination]
		respond_to do |format|
			if @splash_log.save
				cookies[:dmp_splash_seen] = {
					value: 'splash_dialog_seen',
					expires: 3.hours.from_now,
				}
				format.html { redirect_to params[:destination] }
			else
				format.html { redirect_to home_url }
			end
		end
	end
end