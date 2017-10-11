require 'test_helper'

class AccountantTableSearchTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @patient = create :patient, name: 'Susan Everyteen'
    @patient_2 = create :patient, name: 'Thorny'
  end

  describe 'only admins can access billing information' do

  end

  describe 'searching will find relevant patients' do
    before do
      @user.update role: :admin
      @user.reload
      visit authenticated_root_path
      click_link 'Admin tools'
      wait_for_element 'Accounting'
      click_link 'Accounting'
    end
  end
end
