require 'rails_helper'

RSpec.describe GiffyController, type: :controller do
  describe '/giffy' do
    it "should return a Google image search" do
      FakeWeb.register_uri :get,
                           /^https:\/\/www\.google\.com\/search/,
                           body: fixture_file('google', 'gif_results.html')
      stub_user_info
      FakeWeb.register_uri :post,
                           /^https:\/\/hooks\.slack\.com\/services\//,
                           body: 'ok'

      test_slash_command 'giffy', :search, text: 'coolio'

      expect(response.status).to eql(200)
      expect(response.body).to be_empty

      result = JSON.parse(FakeWeb.last_request.body)
      expect(result['channel']).to eql('G048VLWL7')
      expect(result['text']).to match(/^https?:\/\//)
      expect(result['username']).to eql('Giffy')
      expect(result['icon_url']).to start_with('http://test.host/assets/giffy')
      expect(result['icon_emoji']).to be_nil
    end
  end
end
