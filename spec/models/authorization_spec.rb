require 'rails_helper'

RSpec.describe Authorization, type: :model do
  describe '#revoke!' do
    let(:authorization) { FactoryGirl.create :authorization }

    it "should send an API request and delete the record" do
      stub_request(:post, 'https://slack.com/api/auth.revoke').
          with(body: {'token' => authorization.access_token}).
          to_return(body: {'ok' => true, 'revoked' => true}.to_json)

      authorization.revoke!
      expect { authorization.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should raise an error if the token could not be revoked" do
      stub_request(:post, 'https://slack.com/api/auth.revoke').
          with(body: {'token' => authorization.access_token}).
          to_return(body: {'ok' => true, 'revoked' => false, 'error' => 'oops'}.to_json)

      expect { authorization.revoke! }.to raise_error(/Couldn't revoke/)
      expect { authorization.reload }.not_to raise_error
    end
  end
end
