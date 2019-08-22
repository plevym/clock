module LoginParams
  extend ActiveSupport::Concern

  included do
    def login_params
      permitted_params = %i[username email password]
      params.permit(permitted_params)
    end
  end
end
