require 'application_system_test_case'

class GoogleSSOTest < ApplicationSystemTestCase
  describe 'access top page' do
    before { mock_omniauth }
    after { unmock_omniauth }

    describe 'signing in' do
      before { create :user, email: 'test@gmail.com' }

      it 'can sign in with Google Auth Account' do
        visit root_path
        wait_for_element 'Sign in with Google'
        click_link 'Sign in with Google'

        assert has_content? 'Welcome to DCAF'
      end
    end

    it 'will reject sign ins if email is not associated with a user' do
      visit root_path
      assert has_content? 'Sign in'
      click_link 'Sign in with Google'

      assert has_content? 'Sign in'
    end
  end
end
