require 'rails_helper'

RSpec.describe AuthorizationRequestsHelper, type: :helper do
  describe '#oauth_url' do
    it "should return the OAuth URL" do
      expect(helper.oauth_url.to_s).
          to eql('https://slack.com/oauth/authorize?scope=incoming-webhook%2Ccommands%2Cchat%3Awrite%3Auser%2Cchat%3Awrite%3Abot%2Cusers%3Aread&client_id=YOUR_CLIENT_ID')
    end
  end

  describe '#error_message' do
    it "should localize the error message" do
      expect(helper.error_message('access_denied')).to eql("You denied Giffy access to your Slack team.")
    end

    it "should return a default if there is no localization" do
      expect(helper.error_message('foo')).to eql("An error occurred: foo")
    end
  end

  describe '#request_json' do
    it "should return JSON for an invalid request" do
      request = FactoryGirl.build(:authorization_request, code: ' ')
      request.validate
      expect(helper.request_json(request)).to eql({id: nil, status: 'error', error: "Code can’t be blank"}.to_json)
    end

    it "should return JSON for a valid request" do
      stub_request(:post, 'https://slack.com/api/oauth.access').
          to_return(status: 404)

      request = FactoryGirl.create(:authorization_request)
      expect(helper.request_json(request)).to eql({id: request.id, status: request.status, error: nil}.to_json)
    end
  end
end
