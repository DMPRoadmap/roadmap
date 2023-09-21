class ResearchOutputChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    research_output = ResearchOutput.find(params[:id])
    stream_for research_output
  end

  def unsubscribed
    stop_all_streams
  end
end
