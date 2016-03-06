require 'test_helper'

class RecordLookupTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user
    log_in_as @user
  end

  describe 'looking up someone who exists', js: true do 
    before do 
      @patient = create :patient, name: 'Susan Everyteen'
      @pregnancy = create :pregnancy, patient: @patient
    end

    it 'should have a functional search form' do 
      assert_text 'Build your call list' 
      assert has_button? 'Search'
      assert has_field? 'search'
    end

    it 'should retrieve and display a record' do 
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'

      assert has_text? 'Search Results'
      assert has_text? 'Susan Everyteen'
      assert_text @patient.primary_phone
    end
  end

  describe 'looking for someone who does not exist' do 
    it 'should display nothing' do 
    end
  end
end
