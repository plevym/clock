class TimesReport
  require 'csv'
  HEADERS = %w[date check_in check_out hours_worked].freeze

  def initialize(time_checks, timezone)
    timezone ||= 'UTC'

    @time_checks = time_checks
    @timezone    = timezone
    @data        = []

    create_data
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS.dup
      @data.each do |row|
        csv << row
      end
    end
  end

  def to_json
    json_arr = []
    @data.each do |row|
      date, check_in, check_out, hours_worked = row
      json_arr << {
        date: date,
        check_in: check_in,
        check_out: check_out,
        hours_worked: hours_worked
      }
    end

    {
      time_checks: json_arr
    }
  end

  private

  def create_data
    daily_time_checks = []
    @time_checks.each do |time_check|
      daily_time_checks << time_check
      if daily_time_checks.count == 2
        @data << create_work_day(daily_time_checks)
        daily_time_checks = []
      end
    end
  end

  def create_work_day(time_checks)
    date         = time_checks.first.date
    first_time   = time_checks.first.time_checked
    second_time  = time_checks.last.time_checked

    check_in      = time_to_string(first_time)
    check_out     = time_to_string(second_time)
    hours_worked  = hours_worked(time_checks)

    [date, check_in, check_out, hours_worked]
  end

  def hours_worked(time_checks)
    start_time = time_checks.first.time_checked
    end_time   = time_checks.last.time_checked
    time_diff  = end_time - start_time

    Time.at(time_diff.to_i.abs).utc.strftime('%H:%M:%S')
  end

  def time_to_string(time)
    time.in_time_zone(@timezone).strftime('%H:%M:%S')
  end
end
