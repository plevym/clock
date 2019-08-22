module AuthorizationHandler
  extend ActiveSupport::Concern

  included do
    def authorize_request(action, resource = nil)
      token = bearer_token
      raise Clock::Errors::Unauthorized.new unless token.present?

      decoded_token  = JsonWebToken.decode(token)
      permissions    = decoded_token.first['per']
      user_id        = decoded_token.first['user_id']
      has_permission = permissions.include?(PERMISSIONS[action])
      @current_user  = User.find(user_id)

      authorized = has_permission && authorize_action(resource, action)

      raise Clock::Errors::ForbiddenAction.new unless authorized
    end

    def bearer_token
      pattern = /^Bearer /
      header  = request.headers['Authorization']

      header.gsub(pattern, '') if header && header.match(pattern)
    end

    def authorize_action(resource, action)
      return true if resource.nil?

      resource.authorized_action?(@current_user, action)
    end
  end
end
