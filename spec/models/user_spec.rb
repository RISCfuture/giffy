require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#info' do
    it "should JSON-parse the info" do
      expect(FactoryGirl.build(:user).info).to be_kind_of(Hash)
    end
  end

  describe '#stale?' do
    it "should return true if the user is more than one day old" do
      expect(FactoryGirl.build(:user, updated_at: 2.days.ago)).to be_stale
    end
    it "should return false if the user is less than one day old" do
      expect(FactoryGirl.build(:user, updated_at: 1.hour.ago)).not_to be_stale
    end
  end

  describe '#refresh!' do
    it "should update the user's info" do
      stub_user_info
      user = FactoryGirl.create(:user)
      expect { user.refresh! }.to change(user, :info)
      expect(user.info).to eql(JSON.parse(fixture_file('slack', 'userinfo.json')))
    end
  end

  describe '.load' do
    it "should load an existing user by Slack ID" do
      user = FactoryGirl.create(:user)
      expect(User.load(user.slack_id)).to eql(user.info)
    end

    it "should refresh a stale user" do
      user = FactoryGirl.create(:user, updated_at: 1.week.ago)
      expect_any_instance_of(User).to receive(:refresh!).once
      expect(User.load(user.slack_id)).to eql(user.info)
    end

    it "should create a new Slack user" do
      stub_user_info
      expect(User.load('U123457')).to eql(JSON.parse(fixture_file('slack', 'userinfo.json')))
      expect(User.find_by_slack_id('U123457').info).to eql(JSON.parse(fixture_file('slack', 'userinfo.json')))
    end
  end
end
