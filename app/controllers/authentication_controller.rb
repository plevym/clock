class AuthenticationController < ApplicationController
  include ::LoginParams

  def login
    user = User.where(email: login_params[:email])
      .or(User.where(username: login_params[:username])).first

    unless user&.authenticate(login_params[:password])
      raise Clock::Errors::Unauthorized.new
    end

    permissions = []
    user.roles.each do |role|
      permissions << role.permissions.map(&:id)
    end

    payload = {
      user_id: user.id,
      per: permissions.first
    }
    token = JsonWebToken.encode(payload)
    time = Time.now + 24.hours.to_i
    response = {
      token: "Bearer #{token}",
      exp: time.strftime('%m-%d-%Y %H:%M'),
      username: user.username
    }

    json_response(response)
  end
end
