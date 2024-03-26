class PlanChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    plan = Plan.find(params[:id])
    stream_for plan
  end

  def unsubscribed
    stop_all_streams
  end
end
