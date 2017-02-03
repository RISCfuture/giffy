require 'rails_helper'

RSpec.describe MessageDeleteJob, type: :job do
  describe '#perform' do
    let(:authorization) { FactoryGirl.create :authorization }
    let(:payload) {
      {'actions'          => [{'name'  => 'audit_gif',
                               'value' => 'delete'}],
       'callback_id'      => 'TODO',
       'team'             => {'id'     => authorization.team_id,
                              'domain' => FFaker::Internet.user_name(authorization.team_name)},
       'channel'          => {'id' => 'C12345678', 'name' => 'general'},
       'user'             => {'id' => 'U12345678', 'name' => 'sancho'},
       'action_ts'        => '1486091512.986572',
       'message_ts'       => '1486091344.000343',
       'attachment_id'    => '1',
       'token'            => Giffy::Configuration.slack.verification_token,
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
                        'name'  => 'audit_gif',
                        'text'  => 'NopeNopeNope',
                        'type'  => 'button',
                        'value' => 'delete',
                        'style' => 'danger'}]}],
            'type'        => 'message',
            'subtype'     => 'bot_message',
            'ts'          => '1486091344.000343'},
       'response_url'     =>
           'https://test.host/respond'}
    }

    it "should delete a message" do
      stub_request(:post, 'https://slack.com/api/chat.delete').
          with(body: {'channel' => 'C12345678',
                      'token'   => authorization.access_token,
                      'ts'      => '1486091344.000343'}).
          to_return(body: {'ok' => true}.to_json)

      MessageDeleteJob.perform_now payload
    end

    it "should handle Slack errors by attempting to replace the message using the response_url" do
      stub_request(:post, 'https://slack.com/api/chat.delete').
          with(body: {'channel' => 'C12345678',
                      'token'   => authorization.access_token,
                      'ts'      => '1486091344.000343'}).
          to_return(body: {'error' => 'unknown_channel'}.to_json)
      stub_request(:post, 'https://test.host/respond').
          with(body: "{\"text\":\"That GIF was nope’d. Sorry!\",\"attachments\":[]}").
          to_return(body: 'ok')

      MessageDeleteJob.perform_now payload
    end
  end
end
