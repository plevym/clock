FactoryBot.define do
  factory :permission do
    name { Faker::Name.first_name }
  end
end
