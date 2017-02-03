require 'rails_helper'

RSpec.describe LaTeXController, type: :controller do
  include ActiveJob::TestHelper

  around(:each) { |ex| perform_enqueued_jobs { ex.run } }
  before :each do
    @authorization = FactoryGirl.create(:authorization)
  end

  describe "/latex" do
    it "should display a LaTeX image" do
      stub_response = stub_request(:post, 'https://test.host/response').
          to_return(body: 'ok')
      expect(S3).to receive(:put_object).once
      expect(S3).to receive(:put_object_acl).once

      test_slash_command 'latex', :display, authorization: @authorization, overrides: {text: 'y=mx+b'}

      expect(response.status).to eql(200)
      expect(response.body).to be_empty
      expect(stub_response).to have_been_requested
      expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
        sig.uri.to_s == 'https://test.host:443/response' &&
            (json = JSON.parse(sig.body))['response_type'] == 'in_channel' &&
            json['text'] == "*@tim* rendered a LaTeX equation" &&
            json['attachments'].first['fallback'] == 'y=mx+b' &&
            json['attachments'].first['image_url'] == 'https://YOUR_BUCKET.s3-YOUR_REGION.amazonaws.com/images%2Fee668a8b96a7fc367f89135101df6c90.png'
      end).not_to be_nil
    end

    it "should check for insecure LaTeX" do
      expect {
        test_slash_command 'latex', :display, authorization: @authorization, overrides: {text: '\\write{}'}
      }.to raise_error(LaTeX::InsecureCommand)
    end

    it "should error when LaTeX is not installed" do
      allow_any_instance_of(LaTeX).to receive(:system).with('which', 'pdftex').and_return(false)
      allow_any_instance_of(LaTeX).to receive(:system).with('which', 'pdflatex').and_return(false)

      expect {
        test_slash_command 'latex', :display, authorization: @authorization, overrides: {text: 'y=mx+b'}
      }.to raise_error(LaTeX::BinaryNotInstalled)
    end

    it "should error when LaTeX fails to run" do
      allow_any_instance_of(LaTeX).to receive(:system).with(LaTeX.new('-').send(:pdftex), anything, anything, anything).and_return(false)
      allow_any_instance_of(LaTeX).to receive(:system).with('which', anything).and_call_original

      expect {
        test_slash_command 'latex', :display, authorization: @authorization, overrides: {text: 'y=mx+b'}
      }.to raise_error(LaTeX::PDFConversionFailed)
    end

    it "should error when ImageMagick is not installed" do
      allow_any_instance_of(LaTeX).to receive(:system).with('which', 'convert').and_return(false)
      allow_any_instance_of(LaTeX).to receive(:system).with('which', 'pdftex').and_call_original
      allow_any_instance_of(LaTeX).to receive(:system).with('which', 'pdflatex').and_call_original
      allow_any_instance_of(LaTeX).to receive(:system).with(LaTeX.new('-').send(:pdftex), anything, anything, anything).and_call_original

      expect {
        test_slash_command 'latex', :display, authorization: @authorization, overrides: {text: 'y=mx+b'}
      }.to raise_error(LaTeX::BinaryNotInstalled)
    end

    it "should error when ImageMagick fails to run" do
      allow_any_instance_of(LaTeX).to receive(:system).with(LaTeX.new('-').send(:convert), anything, anything, anything,
                                                            anything, anything, anything).and_return(false)
      allow_any_instance_of(LaTeX).to receive(:system).with('which', anything).and_call_original
      allow_any_instance_of(LaTeX).to receive(:system).with(LaTeX.new('-').send(:pdftex), anything, anything, anything).and_call_original

      expect {
        test_slash_command 'latex', :display, authorization: @authorization, overrides: {text: 'y=mx+b'}
      }.to raise_error(LaTeX::PNGConversionFailed)
    end
  end
end
