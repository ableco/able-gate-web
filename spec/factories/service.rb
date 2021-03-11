FactoryBot.define do
  factory :service do
    name { Faker::Company.name }
    identifier { Faker::Name.unique.name }
  end
end
