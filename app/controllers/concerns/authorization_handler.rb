module AuthorizationHandler
  extend ActiveSupport::Concern

  included do
    def authorize_request(action, resource = nil)
      token = bearer_token
      raise Clock::Errors::Unauthorized.new unless token.present?

      decoded_token  = JsonWebToken.decode(token)
      permissions    = decoded_token.first['per']
      user_id        = decoded_token.first['user_id']
      current_user  = User.find_by(id: user_id)

      authorized = authorize_action(permissions, action, current_user, resource)

      raise Clock::Errors::ForbiddenAction.new unless authorized
    end
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']

    header.gsub(pattern, '') if header && header.match(pattern)
  end

  private 

  def authorize_action(permissions, action, user, resource)
    return false if user.nil?
    return true if permissions.include?(PERMISSIONS[action]) &&
                   (resource.nil? || user == resource.owner)

    action_on_any = action.split('_').join('_ANY_')

    permissions.include?(PERMISSIONS[action_on_any])
  end
end
