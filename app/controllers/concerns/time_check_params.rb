module TimeCheckParams
  extend ActiveSupport::Concern

  included do
    def time_check_params
      permitted_params = %i[user_id id time_checked timezone]
      params.permit(permitted_params)
    end
  end
end
