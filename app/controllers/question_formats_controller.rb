class QuestionFormatsController < ApplicationController
  # do we need authorizaton on this? it will only return the URL for the rda api
  # down the line we will add more methods for other external api's
  def rda_api_address
    render json: {
      'url' => QuestionFormat.rda_metadata.first.description
    }.to_json
  end

end
