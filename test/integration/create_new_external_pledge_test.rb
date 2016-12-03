require 'test_helper'

class CreateNewExternalPledgeTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    log_in_as @user
    visit edit_patient_path @patient
  end

  describe 'creating and viewing a pledge' do
    it 'should let you create a new pledge' do
      select 'Baltimore Abortion Fund', from: 'Source'
      fill_in 'Amount', with: '1001'
      click_button 'Create External pledge'

      assert has_content? 'Baltimore Abortion Fund pledge'
      # assert has_content? '1001'
    end
  end
end
