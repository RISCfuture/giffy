FactoryGirl.define do
  factory :authorization do
    ALPHANUM = ('0'..'9').to_a + ('A'..'Z').to_a
    ALPHANUM_AC = ALPHANUM + ('a'..'z').to_a

    access_token do
      [
          'xoxp',
          rand(100_000_000_000).to_s.rjust(11, '0'),
          rand(100_000_000_000).to_s.rjust(11, '0'),
          rand(1_000_000_000_000).to_s.rjust(12, '0'),
          rand(0x100000000000000000000000000000000).to_s(16).rjust(33, '0')
      ].join('-')
    end
    scope { Giffy::Configuration.slack.scopes.join(',') }

    team_name { FFaker::Company.name }
    team_id { 'T' + 8.times.map { ALPHANUM.sample }.join('') }

    incoming_webhook_url do
      webhook_id = 'B' + 8.times.map { ALPHANUM.sample }.join('')
      webhook_token = 24.times.map { ALPHANUM_AC.sample }.join('')
      "https://hooks.slack.com/services/#{team_id}/#{webhook_id}/#{webhook_token}"
    end
    incoming_webhook_channel '#general'
    incoming_webhook_config_url do
      "https://#{FFaker::Internet.user_name(team_name)}.slack.com/services/B401C5SPN/#{incoming_webhook_url.split('/').last}"
    end
  end
end
