require 'test_helper'

class LoggingCallsTest < ActionDispatch::IntegrationTest
  before do 
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @user = create :user
  end

  describe 'logging a reached patient', js: true do 
    before do 
      log_in_as @user
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'
    end

    it 'should' do 
      p page.find('tr', text: 'Susan Everyteen').find('a', text: 'Call')

      assert has_text? 'Susan Everyteen'
      save_and_open_page
      # page.find("#{@patient.id.to_s}")
      # page.find('.call-icon')

      # p find_by_id(@patient.id.to_s)


    end
  end

  describe 'logging a VM or a not home', js: true do 

  end
end
