FactoryBot.define do
  factory :setting do
    project { create(:project) }
    service { create(:service) }
    value { { test: 'abc' }.to_json }
  end
end
