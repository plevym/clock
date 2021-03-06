class User < ApplicationRecord
  has_secure_password
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :time_checks

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }

  def show_attrs
    {
      id: id,
      name: name,
      username: username
    }
  end

  def check_time
    time_checks << TimeCheck.new(time_checked: Time.now.utc)
  end

  def times_report
    TimesReport.new(time_checks.all)
  end

  def admin?
    roles.pluck(:name).include?('admin')
  end

  def owner
    self
  end
end
