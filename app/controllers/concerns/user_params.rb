module UserParams
  extend ActiveSupport::Concern

  included do
    def user_params
      permitted_params = %i[name username email password password_confirmation]
      params.permit(permitted_params)
    end
  end
end
