require 'rails_helper'

RSpec.describe User, type: :model do
  context 'with valid attributes' do
    let(:user_attributes) { attributes_for(:user) }

    it 'is valid' do
      expect(User.new(user_attributes)).to be_valid
    end
  end

  context 'with invalid attributes' do
    let(:user_attributes) { attributes_for(:user) }

    it 'is invalid with invalid email' do
      user_attributes.merge!(email: 'bad_email')

      expect(User.new(user_attributes)).not_to be_valid
    end
  end

  describe '#check_time' do
    let(:user) { create(:user) }

    it 'creates a time_check' do
      user.check_time
      expect(TimeCheck.count).to eq(1)
    end
  end

  describe '#admin?' do
    let(:role) { create(:role, name: 'admin') }
    let(:user) do
      user = create(:user)
      user.roles << role

      user
    end

    context 'with admin role' do
      it 'returns true' do
        expect(user.admin?).to be(true)
      end
    end

    context 'without admin role' do
      before(:each) do
        user.roles = []
      end

      it 'returns false' do
        expect(user.admin?).to be(false)
      end
    end
  end

  describe '#authorized_action?' do
    let(:admin_role) { create(:role, name: 'admin') }
    let(:user_role)  { create(:role, name: 'user') }
    let(:user1) do
      user = create(:user)
      user.roles << admin_role

      user
    end
    let(:user2) do
      user = create(:user)
      user.roles << user_role

      user
    end

    context 'with admin role' do
      it 'returns true' do
        expect(user1.authorized_action?(user1, 'action')).to be(true)
      end
    end

    context 'without admin role' do
      context 'when editing same user' do
        context 'with authorized action' do
          actions = [READ_USER, UPDATE_USERS, CHECK_TIME, CREATE_REPORT]
          action = actions.sample
          it 'returns true' do
            expect(user2.authorized_action?(user2, action)).to be(true)
          end
        end
        context 'with unauthorized action' do
          it 'returns false' do
            expect(user2.authorized_action?(user2, 'unauthorized')).to be(false)
          end
        end
      end

      context 'when editing another user' do
        it 'returns false' do
          expect(user1.authorized_action?(user2, 'action')).to be(false)
        end
      end
    end
  end
end
