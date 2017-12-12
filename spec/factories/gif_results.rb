FactoryBot.define do
  ALPHANUM = ('A'..'Z').to_a + ('0'..'9').to_a

  factory :gif_result do
    association :authorization

    channel_id { 'C' + 8.times { ALPHANUM.sample }.join('') }
    user_id { 'U' + 8.times { ALPHANUM.sample }.join('') }
    user_name { FFaker::Internet.user_name }
    query { FFaker::BaconIpsum.phrase }
    image_url { FFaker::Internet.http_url }
    response_url { FFaker::Internet.http_url }
  end
end
