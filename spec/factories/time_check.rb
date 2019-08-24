FactoryBot.define do
  factory :time_check do
    time_checked { Faker::Time.between(from: DateTime.now - 10.hours, to: DateTime.now) }
  end
end
