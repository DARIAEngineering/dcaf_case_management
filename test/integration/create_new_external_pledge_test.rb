require 'test_helper'
require 'application_system_test_case'

class CreateNewExternalPledgeTest < ApplicationSystemTestCase
  before do
    @user = create :user
    @patient = create :patient
    log_in_as @user
    visit edit_patient_path @patient
    wait_for_element 'Abortion Information'
    click_link 'Abortion Information'
  end

  describe 'creating and viewing a pledge' do
    it 'should let you create a new pledge' do
      select 'Baltimore Abortion Fund', from: 'Source'
      fill_in 'Amount', with: '30000'
      click_button 'Create External pledge'
      wait_for_element 'Patient Information'
      click_link 'Abortion Information'
      wait_for_element 'Abortion information'

      assert has_field? 'Baltimore Abortion Fund pledge', with: '30000'
    end
  end
end
