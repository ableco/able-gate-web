FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    project { create(:project) }
    email { Faker::Internet.email }
    admin { false }
  end
end
