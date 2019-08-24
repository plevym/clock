class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include AuthorizationHandler

  def alive
    json_response(message: 'Service is running')
  end
end
