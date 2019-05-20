require 'application_system_test_case'

# Confirm that user search works like we think it does
class UserSearchesTest < ApplicationSystemTestCase
  before do
    @user = create :user, role: 'admin', email: 'admin_user@dcabortionfund.org'
    @user2 = create :user, role: 'cm',
                           email: 'metallica@test.com',
                           name: 'Metallica'
    @user3 = create :user, role: 'cm', email: 'mind_eraser@test.com'
    log_in_as @user
    visit users_path
  end

  describe 'searching for users' do
    it 'should return matching users on name' do
      fill_in 'Search', with: 'Metallica'
      click_button 'Search'

      within '#user-results' do
        assert has_selector?('tr', count: 1)
      end
    end

    it 'should return matching users on email' do
      fill_in 'Search', with: 'test.com'
      click_button 'Search'

      within '#user-results' do
        assert has_selector?('tr', count: 2)
      end
    end

    it 'should return everybody on blank' do
      click_button 'Search'

      within '#user-results' do
        assert has_selector?('tr', count: 3)
      end
    end
  end
end
