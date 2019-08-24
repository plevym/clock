require 'rails_helper'

RSpec.describe TimeChecksController, type: :controller do
  let(:user_request_body) { attributes_for(:user) }
  let(:auth_headers)      { { 'Authorization' => 'Bearer token' } }

  let(:check) { build(:time_check, time_checked: Time.now - 1.hour) }
    let(:user)   do
      user = create(:user)
      user.time_checks << check

      user
    end

  describe '#index' do
    context 'with correct permissions' do
      let(:decoded_token) do
        [
          {
            'per' => PERMISSIONS.values,
            'user_id' => user.id
          }
        ]
      end

      before(:each) do
        allow(JsonWebToken)
          .to receive(:decode)
          .and_return(decoded_token)

        request.headers.merge!(auth_headers)
      end

      it 'shows all of a user\'s time checks' do
        post(:index, params: { user_id: user.username })

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body.count).to eq(TimeCheck.count)
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        get(:index, params: { user_id: user.username })

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        get(:index, params: { user_id: user.username })

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        get(:index, params: { user_id: user.username })

        expect(response.status).to eq(401)
      end
    end

    context 'with missing permissions' do
      let(:user)          { create(:user) }
      let(:decoded_token) do
        [
          {
            'per' => [],
            'user_id' => user.id
          }
        ]
      end

      before(:each) do
        allow(JWT).to receive(:decode).and_return(decoded_token)
      end

      it 'returns 403' do
        request.headers.merge!(auth_headers)

        get(:index, params: { user_id: user.username })

        expect(response.status).to eq(403)
      end
    end
  end

  describe '#update' do
    let(:params) do
      {
        user_id: user.username,
        id: check.id,
        timezone: 'America/Mexico_City'
      }
    end

    context 'with correct permissions' do
      let(:decoded_token) do
        [
          {
            'per' => PERMISSIONS.values,
            'user_id' => user.id
          }
        ]
      end

      before(:each) do
        allow(JsonWebToken)
          .to receive(:decode)
          .and_return(decoded_token)

        request.headers.merge!(auth_headers)
      end

      it 'updates a time check' do
        time          = Time.now - 10.minute
        expected_time = time.in_time_zone('America/Mexico_City')
                            .strftime('%d/%m/%Y %H:%M:%S %z')

        params.merge!(time_checked: time.strftime('%d/%m/%Y %H:%M:%S%z'))

        patch(:update, params: params)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body['time_checked']).to eq(expected_time)
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        patch(:update, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        patch(:update, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        patch(:update, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with missing permissions' do
      let(:decoded_token) do
        [
          {
            'per' => [],
            'user_id' => user.id
          }
        ]
      end

      before(:each) do
        allow(JWT).to receive(:decode).and_return(decoded_token)
      end

      it 'returns 403' do
        request.headers.merge!(auth_headers)

        patch(:update, params: params)

        expect(response.status).to eq(403)
      end
    end
  end
end
