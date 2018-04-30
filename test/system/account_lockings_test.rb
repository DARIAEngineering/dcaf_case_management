require "application_system_test_case"

class AccountLockingsTest < ApplicationSystemTestCase
  before do
    @admin = create :user, role: :admin
    @locked_user = create :user, role: :cm, disabled_by_fund: true
    @unlocked_user  = create :user, role: :cm
  end

  describe 'admin locking' do
    before do
      log_in_as @admin
      visit users_path
    end

    it 'should prevent you from locking yourself' do
      within :css, "#user-#{@admin.id}" do
        click_link 'Lock account'
      end
      assert has_content? 'Ask another admin'
    end

    it 'should let you lock other users' do
      within :css, "#user-#{@unlocked_user.id}" do
        click_link 'Lock account'
      end
      assert has_content? "Locked #{@unlocked_user.name}'s account"

      within :css, "#user-#{@unlocked_user.id}" do
        click_link 'Unlock account'
      end
      assert has_content? "Unlocked #{@unlocked_user.name}'s account"
    end
  end

  describe 'locked account behavior' do
    it 'should prevent you from logging in' do
      log_in @locked_user
      assert_equal current_path, new_user_session_path
      assert has_content? 'Account currently locked'
    end
  end
end
