FactoryBot.define do
  factory :action_log do
    user { nil }
    project { nil }
    service { nil }
    operation { 1 }
    status { 1 }
    note { "MyText" }
  end
end
