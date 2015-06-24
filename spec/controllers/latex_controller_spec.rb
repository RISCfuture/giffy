require 'rails_helper'

RSpec.describe LatexController, type: :controller do
  describe "/latex" do
    it "should display a LaTeX image" do
      stub_user_info
      FakeWeb.register_uri :post,
                           /^https:\/\/hooks\.slack\.com\/services\//,
                           body: 'ok'
      expect(S3).to receive(:put_object).once
      expect(S3).to receive(:put_object_acl).once

      test_slash_command 'latex', :display, text: 'y=mx+b'

      expect(response.status).to eql(200)
      expect(response.body).to be_empty

      result = JSON.parse(FakeWeb.last_request.body)
      expect(result['channel']).to eql('G048VLWL7')
      expect(result['text']).to eql('https://giffy-latex.s3-us-west-1.amazonaws.com/images/b168649683c458a25521cf6003e389c6.png')
    end
  end
end
