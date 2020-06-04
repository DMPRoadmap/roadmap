module Dmpopidor
  module Controllers
    module FeedbackRequests
      ALERT = _("Unable to submit your request for feedback at this time.")
      ERROR = _("An error occurred when requesting feedback for this plan.")
      # CHANGES : Changed feedback request message
      def create
        @plan = Plan.find(params[:plan_id])
        authorize @plan, :request_feedback?
        begin
          if @plan.request_feedback(current_user)
            redirect_to request_feedback_plan_path(@plan), notice: _('Feedback has been requested.')
          else
            redirect_to request_feedback_plan_path(@plan), alert: ALERT
          end
        rescue Exception
          redirect_to request_feedback_plan_path(@plan), alert: ERROR
        end
      end
    end
  end
end