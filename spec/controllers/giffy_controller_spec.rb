require 'rails_helper'

RSpec.describe GiffyController, type: :controller do
  describe '/giffy' do
    it "should return a Google image search" do
      FakeWeb.register_uri :get,
                           'http://ajax.googleapis.com/ajax/services/search/images?imgtype=animated&q=coolio&rsz=8&safe=high&userip=0.0.0.0&v=1.0',
                           body: fixture_file('google', 'gif_results.json')
      stub_user_info
      FakeWeb.register_uri :post,
                           /^https:\/\/hooks\.slack\.com\/services\//,
                           body: 'ok'

      test_slash_command 'giffy', :search, text: 'coolio'

      expect(response.status).to eql(200)
      expect(response.body).to be_empty

      result = JSON.parse(FakeWeb.last_request.body)
      expect(result['channel']).to eql('G048VLWL7')
      expect(result['text']).to match(/^https?:\/\//)
      expect(result['username']).to eql('Giffy')
      expect(result['icon_url']).to eql('http://test.host/assets/giffy.png')
      expect(result['icon_emoji']).to be_nil
    end

    it "should return a private sad response when there are no matches" do
      FakeWeb.register_uri :get,
                           'http://ajax.googleapis.com/ajax/services/search/images?imgtype=animated&q=dfgonj%3Begrs%3Bhiuogaewr%3Buhjigwar%3Bhuiowaegrv&rsz=8&safe=high&userip=0.0.0.0&v=1.0',
                           body: fixture_file('google', 'no_results.json')
      stub_user_info

      test_slash_command 'giffy', :search, text: 'dfgonj;egrs;hiuogaewr;uhjigwar;huiowaegrv'

      expect(response.status).to eql(404)
      expect(response.body).to eql("Giffy couldn’t find a matching GIF :(")
    end
  end
end
