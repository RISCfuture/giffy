require 'rails_helper'

RSpec.describe OtherController, type: :controller do
  describe "/glare" do
    it "should glare" do
      stub_user_info
      FakeWeb.register_uri :post,
                           /^https:\/\/hooks\.slack\.com\/services\//,
                           body: 'ok'

      test_slash_command 'glare', :glare, text: 'angry stuff'

      expect(response.status).to eql(200)
      expect(response.body).to be_empty

      result = JSON.parse(FakeWeb.last_request.body)
      expect(result['channel']).to eql('G048VLWL7')
      expect(result['text']).to eql('ಠ_ಠ angry stuff')
    end
  end
end
