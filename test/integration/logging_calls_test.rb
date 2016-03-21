require 'test_helper'

class LoggingCallsTest < ActionDispatch::IntegrationTest
  before do 
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @user = create :user
    log_in_as @user
  end

  describe 'logging a reached patient', js: true do 
    before do 
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'
      # page.execute_script
    end

    it 'should' do 
      # modal = window_opened_by { page.find('tr', text: 'Susan Everyteen').find('span', text: 'Call').click }
      # p 
      # within_window(modal) do 
        # assert has_text 'Call Susan Everyteen'
      # end

      save_and_open_page

      # page.find('tr', text: 'Susan Everyteen').find('span', text: 'Call').click.accept_modal

      # assert has_text? 'Susan Everyteen'
      # page.find("#{@patient.id.to_s}")
      # page.find('.call-icon')

      # p find_by_id(@patient.id.to_s)


    end
  end

  describe 'logging a VM or a not home', js: true do 

  end
end
