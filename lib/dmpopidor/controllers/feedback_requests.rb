module Dmpopidor
  module Controllers
    module FeedbackRequests
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