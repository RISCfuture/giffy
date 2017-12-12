FactoryBot.define do
  factory :authorization_request do
    code do
      [rand(100_000_000_000).to_s.rjust(11, '0'),
       rand(1_000_000_000_000).to_s.rjust(12, '0'),
       rand(0x10000000000).to_s(16).rjust(10, '0')].join('.')
    end
  end
end
