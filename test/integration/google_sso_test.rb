require 'application_system_test_case'

class GoogleSSOTest < ApplicationSystemTestCase
  describe 'access top page' do
    before do
      @user = create :user, email: 'test@gmail.com', name: 'yologoat'
      mock_omniauth
    end

    it 'can sign in with Google Auth Account' do
      visit root_path
      wait_for_element 'Sign in with Google'
      click_link 'Sign in with Google'

      assert has_content? @user.name
    end

    it 'will reject sign ins if email is not associated with a user' do
      visit root_path
      assert has_content? 'Sign in'
      click_link 'Sign in with Google'

      assert has_content? 'Sign in'
    end
  end
end
