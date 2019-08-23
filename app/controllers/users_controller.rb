class UsersController < ApplicationController
  include ActionController::MimeResponds
  include ::UserParams

  before_action :find_user, except: %i[index create]

  def index
    authorize_request(READ_USERS)

    json_response(User.all.map(&:show_attrs))
  end

  def show
    authorize_request(READ_USER, @user)

    json_response(@user.show_attrs)
  end

  def create
    authorize_request(CREATE_USERS)

    user = User.create!(user_params)

    json_response(user.show_attrs)
  end

  def update
    authorize_request(UPDATE_USER, @user)

    @user.update!(user_params)

    json_response(@user.show_attrs)
  end

  def destroy
    authorize_request(DELETE_USERS, @user)

    @user.destroy
  end

  def check_time
    authorize_request(CHECK_TIME, @user)

    @user.check_time
  end

  def report
    authorize_request(CREATE_REPORT, @user)

    data = TimesReport.new(@user.time_checks.all, params[:timezone])

    respond_to do |format|
      format.json do
        json_response(data.to_json)
      end

      format.csv do
        send_data(
          data.to_csv,
          filename: "#{@user.name}-#{Date.today}.csv"
        )
      end
    end
  end

  private

  def find_user
    @user = User.find_by!(username: params[:id])
  end
end
