class TimeCheck < ApplicationRecord
  belongs_to :user

  def date
    created_at.strftime('%d/%m/%Y')
  end

  def owner
    user
  end
end
