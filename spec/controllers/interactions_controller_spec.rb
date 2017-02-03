require 'rails_helper'

RSpec.describe InteractionsController, type: :controller do
  include ActiveJob::TestHelper

  around(:each) { |ex| perform_enqueued_jobs { ex.run } }

  describe '#handle' do
    let(:authorization) { FactoryGirl.create(:authorization) }
    let(:action_name) { 'other' }
    let(:action_value) { 'other' }
    let(:verification_token) { Giffy::Configuration.slack.verification_token }
    let(:payload) {
      {'actions'          => [{'name'  => action_name,
                               'value' => action_value}],
       'callback_id'      => 'TODO',
       'team'             => {'id'     => authorization.team_id,
                              'domain' => FFaker::Internet.user_name(authorization.team_name)},
       'channel'          => {'id' => 'C12345678', 'name' => 'general'},
       'user'             => {'id' => 'U12345678', 'name' => 'sancho'},
       'action_ts'        => '1486091512.986572',
       'message_ts'       => '1486091344.000343',
       'attachment_id'    => '1',
       'token'            => verification_token,
       'original_message' =>
           {'text'        => "*@sancho* searched for _coolio_ using /giffy",
            'username'    => 'Giffy',
            'bot_id'      => 'B12345678',
            'attachments' =>
                [{'fallback'     => 'Another excellent GIF from Giffy',
                  'image_url'    => 'http://img.memecdn.com/me-when-i-delete-porn_o_727732.gif',
                  'image_width'  => 267,
                  'image_height' => 200,
                  'image_bytes'  => 893900,
                  'is_animated'  => true,
                  'callback_id'  => 'TODO',
                  'id'           => 1,
                  'actions'      =>
                      [{'id'    => '1',
                        'name'  => action_name,
                        'text'  => 'NopeNopeNope',
                        'type'  => 'button',
                        'value' => action_value,
                        'style' => 'danger'}]}],
            'type'        => 'message',
            'subtype'     => 'bot_message',
            'ts'          => '1486091344.000343'},
       'response_url'     =>
           "https://hooks.slack.com/actions/#{FFaker::Internet.user_name authorization.team_name}/136384582595/zuIt0HDCbEbBvoV3LbozsV0f"}
    }

    context '[name=audit_gif]' do
      let(:action_name) { 'audit_gif' }

      context '[value=delete]' do
        let(:action_value) { 'delete' }

        it "should delete the message" do
          stub_delete = stub_request(:post, 'https://slack.com/api/chat.delete').
              with(:body => {'channel' => 'C12345678',
                             'token'   => authorization.access_token,
                             'ts'      => '1486091344.000343'}).
              to_return(body: {'ok' => true}.to_json)

          post :handle, params: {payload: payload.to_json}
          expect(response.status).to eql(200)
          expect(stub_delete).to have_been_requested
        end
      end

      context '[value=other]' do
        it "should respond with 422" do
          post :handle, params: {payload: payload.to_json}
          expect(response.status).to eql(422)
        end
      end

      context '[invalid verification token]' do
        let(:action_name) { 'audit_gif' }
        let(:action_value) { 'delete' }
        let(:verification_token) { 'haxxed' }

        it "should respond with 403" do
          post :handle, params: {payload: payload.to_json}
          expect(response.status).to eql(401)
        end
      end
    end

    context '[name=other]' do
      it "should respond with 422" do
        post :handle, params: {payload: payload.to_json}
        expect(response.status).to eql(422)
      end
    end
  end
end
