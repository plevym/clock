require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user_request_body) { attributes_for(:user) }
  let(:auth_headers)      { { 'Authorization' => 'Bearer token' } }

  describe '#create' do
    context 'with correct permissions' do
      let(:user)          { create(:user) }
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

      context 'with valid parameters' do
        it 'creates a user' do
          post(:create, params: user_request_body)

          body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(body).to be_present
          expect(body['id']).to be_present
        end
      end

      context 'with invalid parameters' do
        it 'returns 422' do
          user_request_body.delete(:email)

          post(:create, params: user_request_body)

          body = JSON.parse(response.body)

          expect(response.status).to eq(422)
          expect(body).to be_present
        end
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        post(:create, params: user_request_body)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:create, params: user_request_body)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:create, params: user_request_body)

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

        post(:create, params: user_request_body)

        expect(response.status).to eq(403)
      end
    end
  end

  describe '#index' do
    context 'with correct permissions' do
      let(:users)         { create_list(:user, 5) }
      let(:decoded_token) do 
        [
          {
            'per' => PERMISSIONS.values,
            'user_id' => users.first.id
          }
        ]
      end

      before(:each) do
        allow(JsonWebToken)
          .to receive(:decode)
          .and_return(decoded_token)

        request.headers.merge!(auth_headers)
      end

      it 'returns all users' do
        post(:index)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body.count).to eq(users.count)
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        post(:index)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:index)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:index)

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

        post(:index)

        expect(response.status).to eq(403)
      end
    end
  end

  describe '#update' do
    let(:user)   { create(:user) }
    let(:params) do
      {
        id: user.username,
        name: 'new_name'
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

      it 'updates a user' do
        patch(:update, params: params)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body['name']).to eq('new_name')
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        post(:index)

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

        patch(:update, params: params)

        expect(response.status).to eq(403)
      end
    end
  end

  describe '#delete' do
    let(:user)   { create(:user) }
    let(:params) do
      {
        id: user.username
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

      it 'deletes a user' do
        delete(:destroy, params: params)

        expect(response.status).to eq(204)
        expect(User.count).to eq(0)
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        delete(:destroy, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        delete(:destroy, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        delete(:destroy, params: params)

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

        delete(:destroy, params: params)

        expect(response.status).to eq(403)
      end
    end
  end

  describe '#show' do
    let(:user)   { create(:user) }
    let(:params) do
      {
        id: user.username
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

      it 'shows a user' do
        get(:show, params: params)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body['id']).to eq(user.id)
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        get(:show, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        get(:show, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        get(:show, params: params)

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

        get(:show, params: params)

        expect(response.status).to eq(403)
      end
    end
  end

  describe '#check_time' do
    let(:user)   { create(:user) }
    let(:params) do
      {
        id: user.username
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

      it 'creates a time_check' do
        post(:check_time, params: params)

        expect(response.status).to eq(204)
        expect(TimeCheck.count).to eq(1)
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        post(:check_time, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:check_time, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:check_time, params: params)

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

        post(:check_time, params: params)

        expect(response.status).to eq(403)
      end
    end
  end

  describe 'report' do
    let(:check1) { build(:time_check, created_at: Time.now - 1.hour) }
    let(:check2) { build(:time_check) }
    let(:user)   do
      user = create(:user)
      user.time_checks << check1
      user.time_checks << check2

      user
    end
    let(:params) do
      {
        id: user.username,
        format: 'json'
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

      it 'creates a json report' do
        post(:report, params: params)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body['time_checks'].first['hours_worked']).to eq('01:00:00')
      end

      it 'creates a csv report' do
        params.merge!(format: 'csv')

        post(:report, params: params)

        expect(response.status).to eq(200)
        expect(response.body).to be_present
        expect(response.body.split("\n").last.split(',').last).to eq('01:00:00')
      end
    end

    context 'with no authorization token' do
      it 'returns 401' do
        post(:report, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with invalid authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ImmatureSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:report, params: params)

        expect(response.status).to eq(401)
      end
    end

    context 'with expired authorization token' do
      before(:each) do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
      end

      it 'returns 401' do
        request.env.merge!(auth_headers)

        post(:report, params: params)

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

        post(:report, params: params)

        expect(response.status).to eq(403)
      end
    end
  end
end
