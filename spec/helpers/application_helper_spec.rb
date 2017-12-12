require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#oauth_url' do
    it "should return the OAuth URL" do
      expect(helper.oauth_url.to_s).
          to eql('https://slack.com/oauth/authorize?scope=incoming-webhook%2Ccommands%2Cchat%3Awrite%3Auser%2Cchat%3Awrite%3Abot%2Cusers%3Aread%2Cgroups%3Aread&client_id=YOUR_CLIENT_ID')
    end
  end
end
