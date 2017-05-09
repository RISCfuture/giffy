require 'rails_helper'

RSpec.describe AuthorizationRequestsController, type: :controller do
  include ActiveJob::TestHelper

  around(:each) { |ex| perform_enqueued_jobs { ex.run } }

  describe '#new' do
    it "should render the 'new' template" do
      get :new
      expect(response.status).to eql(200)
      expect(response).to render_template('new')
    end
  end

  describe '#create' do
    context "[given an error]" do
      let(:error) { 'invalid_token' }

      before :each do
        get :create, params: {error: error}
      end

      it "should redirect with error" do
        expect(response).to redirect_to(root_url(error: error))
      end
    end

    context "[given a code]" do
      let(:code) { rand(1_000_000).to_s.rjust(7, '0') }
      let(:template_authorization) { FactoryGirl.build(:authorization) }
      let(:response_body) do
        {
            'ok'               => true,
            'access_token'     => template_authorization.access_token,
            'scope'            => template_authorization.scope,
            'team_name'        => template_authorization.team_name,
            'team_id'          => template_authorization.team_id,
            'incoming_webhook' => {
                'url'               => template_authorization.incoming_webhook_url,
                'channel'           => template_authorization.incoming_webhook_channel,
                'configuration_url' => template_authorization.incoming_webhook_config_url
            }
        }
      end

      before :each do
        stub_request(:post, 'https://slack.com/api/oauth.access').
            with(body: {
                'client_id'     => 'YOUR_CLIENT_ID',
                'client_secret' => 'YOUR_CLIENT_SECRET',
                'code'          => code}).
            to_return(body: response_body.to_json)

        get :create, params: {code: code}
      end

      it "should create an authorization request and redirect" do
        expect(AuthorizationRequest.count).to eql(1)
        authorization_request = AuthorizationRequest.first

        expect(authorization_request.code).to eql(code)
        expect(authorization_request).to be_success

        expect(authorization_request.authorization).not_to be_nil
        expect(authorization_request.authorization.access_token).to eql(template_authorization.access_token)
        expect(authorization_request.authorization.scope).to eql(template_authorization.scope)
        expect(authorization_request.authorization.team_name).to eql(template_authorization.team_name)
        expect(authorization_request.authorization.team_id).to eql(template_authorization.team_id)
        expect(authorization_request.authorization.incoming_webhook_url).to eql(template_authorization.incoming_webhook_url)
        expect(authorization_request.authorization.incoming_webhook_channel).to eql(template_authorization.incoming_webhook_channel)
        expect(authorization_request.authorization.incoming_webhook_config_url).to eql(template_authorization.incoming_webhook_config_url)

        expect(response).to redirect_to(root_url(authorization_request_id: authorization_request.id))
      end

      context '[authorization error]' do
        let(:response_body) do
          {
              'ok'    => false,
              'error' => 'invalid_code'
          }
        end

        it "should handle authorization errors" do
          expect(AuthorizationRequest.count).to eql(1)
          authorization_request = AuthorizationRequest.first

          expect(authorization_request.authorization).to be_nil
          expect(authorization_request).to be_error
          expect(authorization_request.error).to eql('Slack API error: invalid_code')
        end
      end

      context '[invalid code]' do
        let(:code) { ' ' }

        it "should handle a validation error" do
          expect(response).to redirect_to(root_url(error: 'invalid_authorization_request'))
        end
      end
    end
  end

  describe '#show' do
    let(:authorization_request) do
      stub_request(:post, 'https://slack.com/api/oauth.access').
          to_return(status: 404)
      FactoryGirl.create :authorization_request
    end

    it "should render the JSON template" do
      get :show, params: {id: authorization_request.to_param, format: 'json'}
      expect(response.status).to eql(200)
      expect(response).to render_template('show')
    end
  end
end
