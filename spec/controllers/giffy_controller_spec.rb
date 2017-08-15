require 'rails_helper'

RSpec.describe GiffyController, type: :controller do
  include ActiveJob::TestHelper

  around(:each) { |ex| perform_enqueued_jobs { ex.run } }
  before :each do
    @authorization = FactoryGirl.create(:authorization)

    stub_request(:post, 'https://slack.com/api/groups.list').
        to_return(body: {ok:     true,
                         groups: [{id:   'G123457',
                                   name: 'secretplans'}]}.to_json)
  end

  describe '/giffy' do
    it "should return a Google image search" do
      stub_response = stub_request(:post, 'https://test.host/response').
          to_return(body: 'ok')
      stub_request(:get, 'https://www.google.com/search?as_q=coolio&as_st=y&gws_rd=ssl&tbm=isch&tbs=itp:animated').
          to_return(body: fixture_file('google', 'gif_results.html'))

      test_slash_command 'giffy', :search, authorization: @authorization, overrides: {text: 'coolio'}

      expect(response.status).to eql(200)
      expect(response.body).to be_empty
      expect(stub_response).to have_been_requested.twice # once for the button delete
      # original request
      expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
        sig.uri.to_s == 'https://test.host:443/response' &&
            (json = JSON.parse(sig.body))['response_type'] == 'in_channel' &&
            json['text'] != nil &&
            json['attachments'].first['image_url'] != nil &&
            json['attachments'].first['attachment_type'] == 'default' &&
            json['attachments'].first['actions']&.first&.fetch('name') == 'audit_gif' &&
            json['attachments'].first['actions']&.first&.fetch('type') == 'button' &&
            json['attachments'].first['actions']&.first&.fetch('value') == 'delete' &&
            json['attachments'].first['actions']&.first&.fetch('style') == 'danger'
      end).not_to be_nil
      # follow-up request w/o buttons
      expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
        sig.uri.to_s == 'https://test.host:443/response' &&
            (json = JSON.parse(sig.body))['response_type'] == 'in_channel' &&
            json['text'] != nil &&
            json['attachments'].first['image_url'] != nil &&
            json['attachments'].first['attachment_type'] == 'default' &&
            json['attachments'].first['actions'].empty?
      end).not_to be_nil
    end

    it "should handle no results" do
      stub_response = stub_request(:post, 'https://test.host/response').
          to_return(body: 'ok')
      stub_request(:get, 'https://www.google.com/search?as_q=coolio&as_st=y&gws_rd=ssl&tbm=isch&tbs=itp:animated').
          to_return(body: fixture_file('google', 'no_results.html'))

      test_slash_command 'giffy', :search, authorization: @authorization, overrides: {text: 'coolio'}

      expect(response.status).to eql(200)
      expect(response.body).to be_empty
      expect(stub_response).to have_been_requested
      expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
        sig.uri.to_s == 'https://test.host:443/response' &&
            (json = JSON.parse(sig.body))['text'] != nil &&
            json['response_type'] == 'in_channel'
      end).not_to be_nil
    end

    context '[private channel]' do
      before :each do
        stub_request(:post, 'https://test.host/response').
            to_return(body: 'ok')
        stub_request(:get, 'https://www.google.com/search?as_q=coolio&as_st=y&gws_rd=ssl&tbm=isch&tbs=itp:animated').
            to_return(body: fixture_file('google', 'gif_results.html'))
      end

      it "should return a sorry message" do
        test_slash_command 'giffy', :search, authorization: @authorization, overrides: {channel_id: 'G123456', text: 'coolio'}

        expect(response.status).to eql(200)
        expect(response.body).to be_empty

        expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
          sig.uri.to_s == 'https://test.host:443/response' &&
              (json = JSON.parse(sig.body))['response_type'] == 'ephemeral' &&
              json['text'].include?('Sorry')
        end).not_to be_nil
      end

      it "should allow a private channel that the user is a member of" do
        test_slash_command 'giffy', :search, authorization: @authorization, overrides: {channel_id: 'G123457', text: 'coolio'}

        expect(response.status).to eql(200)
        expect(response.body).to be_empty

        expect(WebMock::RequestRegistry.instance.requested_signatures.hash.detect do |sig, _|
          sig.uri.to_s == 'https://test.host:443/response' &&
              (json = JSON.parse(sig.body))['response_type'] == 'in_channel' &&
              json['text'] != nil &&
              json['attachments'].first != nil
        end).not_to be_nil
      end
    end
  end
end
