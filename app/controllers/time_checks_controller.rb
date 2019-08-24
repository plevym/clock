class TimeChecksController < ApplicationController
  DEFAULT_TIME_ZONE = 'UTC'.freeze
  DATE_FORMAT = '%d/%m/%Y %H:%M:%S%z'.freeze

  include ::TimeCheckParams

  before_action :find_time_check, only: :update

  def index
    authorize_request(READ_TIMECHECKS)

    @user    = User.find_by!(username: time_check_params[:user_id])
    timezone = time_check_params.fetch(:timezone, DEFAULT_TIME_ZONE)

    response = @user.time_checks.map do |time_check|
      time_check.show_attrs(timezone)
    end

    json_response(response)
  end

  def update
    authorize_request(UPDATE_TIMECHECK)

    params = time_check_params

    unless params[:time_checked]
           .match?(/^\d{2}\/\d{2}\/\d{4}\s\d{2}:\d{2}:\d{2}\S+$/)
      @time_check.errors.add(:time_checked, 'invalid format')
      raise ActiveRecord::RecordInvalid.new(@time_check)
    end

    new_time   = DateTime.strptime(params[:time_checked], DATE_FORMAT)
    timezone   = params.delete(:timezone)
    timezone ||= DEFAULT_TIME_ZONE

    update_params = params.merge(
      user: @time_check.user,
      time_checked: new_time.utc
    )

    @time_check.update!(update_params)

    json_response(@time_check.show_attrs(timezone))
  end

  private

  def find_time_check
    @time_check = TimeCheck.find(params[:id])
  end
end
