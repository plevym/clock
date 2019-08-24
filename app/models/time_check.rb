class TimeCheck < ApplicationRecord
  belongs_to :user

  def date
    created_at.strftime('%d/%m/%Y')
  end

  def show_attrs(timezone)
    time = time_checked.in_time_zone(timezone).strftime('%d/%m/%Y %H:%M:%S %z')

    {
      id: id,
      time_checked: time
    }
  end

  def owner
    user
  end
end
