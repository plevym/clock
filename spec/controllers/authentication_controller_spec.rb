require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  let(:user)         { create(:user) }
  let(:login_params) do
    {
      email:     user.email,
      password: 'password'
    }
  end
  describe '#login' do
    context 'with correct credentials' do
      it 'returns status 200 and a token' do
        response = post(:login, params: login_params)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to be_present
        expect(body['token']).to be_present
        expect(body['token']).to match(/^Bearer /)
      end
    end

    context 'with incorrect credentials' do
      context 'with incorrect user' do
        it 'returns status 401' do
          login_params[:email] = 'wrong_email'

          response = post(:login, params: login_params)

          expect(response.status).to eq(401)
        end
      end

      context 'with incorrect password' do
        it 'returns status 401' do
          login_params[:password] = 'wrong_password'

          response = post(:login, params: login_params)

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
