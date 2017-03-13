require 'rails_helper'
require 'comic_sans'

RSpec.describe ComicSansController, type: :controller do
  include ActiveJob::TestHelper

  around(:each) { |ex| perform_enqueued_jobs { ex.run } }
  before :each do
    @authorization = FactoryGirl.create(:authorization)
  end

  describe '/comicsans' do
    it "should generate an image and upload it" do
      stub_response = stub_request(:post, 'https://test.host/response').
          to_return(body: 'ok')
      expect(S3).to receive(:put_object).once
      expect(S3).to receive(:put_object_acl).once

      test_slash_command 'comicsans', :display, authorization: @authorization, overrides: {text: "Hello, world!"}

      expect(response.status).to eql(200)
      expect(response.body).to be_empty
      expect(stub_response).to have_been_requested
      expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
        sig.uri.to_s == 'https://test.host:443/response' &&
            (json = JSON.parse(sig.body))['response_type'] == 'in_channel' &&
            json['text'] == "*@tim* used /comicsans" &&
            json['attachments'].first['fallback'] == "Hello, world!" &&
            json['attachments'].first['image_url'] == 'https://YOUR_BUCKET.s3-YOUR_REGION.amazonaws.com/images%2F6cd3556deb0da54bca060b4c39479839.png'
      end).not_to be_nil
    end

    it "should error when ImageMagick is not installed" do
      allow_any_instance_of(ComicSans).to receive(:system).with('which', 'convert').and_return(false)

      expect {
        test_slash_command 'comicsans', :display, authorization: @authorization, overrides: {text: "Hello, world!"}
      }.to raise_error(ComicSans::BinaryNotInstalled)
    end

    it "should error when ImageMagick fails to run" do
      allow_any_instance_of(ComicSans).to receive(:system).with(ComicSans.new('-').send(:convert), anything, anything, anything,
                                                            anything, anything, anything, anything).and_return(false)
      allow_any_instance_of(ComicSans).to receive(:system).with('which', anything).and_call_original

      expect {
        test_slash_command 'comicsans', :display, authorization: @authorization, overrides: {text: "Hello, world!"}
      }.to raise_error(ComicSans::PNGConversionFailed)
    end
  end
end
