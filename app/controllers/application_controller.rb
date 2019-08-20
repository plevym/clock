class ApplicationController < ActionController::API
  include Response

  def alive
    json_response(message: 'Service is running')
  end
end
