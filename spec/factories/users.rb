FactoryGirl.define do
  factory :user do
    sequence(:slack_id) { |i| 'U' + i.to_s }
    info { fixture_file('slack', 'userinfo.json').sub 'U02AY8HK2', slack_id }
  end
end
