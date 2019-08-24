module ExceptionHandler
  extend ActiveSupport::Concern

  ERRORS = {
    bad_request: {
      code:    4000,
      message: "Param is missing or the value is empty: %s"
    },
    token_expired: {
      code:    4010,
      message: 'Expired token'
    },
    unauthorized: {
      code:    4011,
      message: 'Unauthorized'
    },
    forbidden: {
      code:    4030,
      message: 'Forbidden action'
    },
    not_found: {
      code:    4040,
      message: "%s not found"
    },
    unprocessable_entity: {
      code:    4220,
      message: 'Invalid form'
    },
    wrong_format: {
      code: 4060,
      message: 'Format not supported'
    }
  }.freeze

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      error           = ERRORS[:not_found]
      error[:message] = error[:message] % e.model

      json_response(error, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      errors = e.record.errors.messages.map do |key, value|
        {
          field:    key.to_s,
          messages: value
        }
      end

      body = ERRORS[:unprocessable_entity].merge(errors: errors)

      json_response(body, :unprocessable_entity)
    end

    rescue_from ActionController::ParameterMissing do |e|
      error           = ERRORS[:bad_request]
      error[:message] = error[:message] % e.param

      json_response(error, :bad_request)
    end

    rescue_from Clock::Errors::ForbiddenAction do |e|
      json_response(ERRORS[:forbidden], :forbidden)
    end

    rescue_from Clock::Errors::Unauthorized do |e|
      json_response(ERRORS[:unauthorized], :unauthorized)
    end

    rescue_from Clock::Errors::ExpiredToken do |e|
      json_response(ERRORS[:token_expired], :unauthorized)
    end

    rescue_from ActionController::UnknownFormat do |e|
      error           = ERRORS[:wrong_format]
      error[:message] = error[:message] % e.model

      json_response(error, :not_acceptable)
    end
  end
end
