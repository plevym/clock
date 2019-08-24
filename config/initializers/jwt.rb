class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY)
  rescue JWT::ExpiredSignature
    raise Clock::Errors::ExpiredToken.new
  rescue JWT::ImmatureSignature
    raise Clock::Errors::Unauthorized.new
  end
end
