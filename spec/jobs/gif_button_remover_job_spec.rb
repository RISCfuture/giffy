require 'rails_helper'

RSpec.describe GIFButtonRemoverJob, type: :job do
  describe '#perform' do
    let(:authorization) { FactoryBot.create :authorization }
    let(:command) do
      Slack::Command.new authorization.access_token,
                         authorization.team_id,
                         FFaker::Internet.user_name(authorization.team_name),
                         'C12345678',
                         'general',
                         'U12345678',
                         'sancho',
                         'giffy',
                         "test test",
                         'https://test.host/respond'
    end
    let(:timestamp) { (rand*1_000_000).to_s }
    let(:image) { 'https://test.host/respond' }
    let(:gif_result) { GIFResult.create!(authorization: authorization, command: command, image_url: image) }

    it "should send update the message" do
      stub_request(:post, 'https://test.host/respond').
          with(body: {response_type:    'in_channel',
                      replace_original: true,
                      text:             "*@sancho* searched for _test test_ using /giffy",
                      attachments:      [{
                                             image_url:       image,
                                             attachment_type: 'default',
                                             fallback:        "One piping-hot GIF brought to you courtesy of /giffy!",
                                             callback_id:     gif_result.id,
                                             actions:         []
                                         }]}.to_json).
          to_return(body: {'ok' => true}.to_json)

      GIFButtonRemoverJob.perform_now gif_result
    end
  end
end
