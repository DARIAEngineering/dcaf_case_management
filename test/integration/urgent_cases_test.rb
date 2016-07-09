require 'test_helper'

class UrgentCasesTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient, urgent_flag: true
    @user = create :user
    log_in_as @user
  end

  after do
    Capybara.use_default_driver
  end

  describe 'urgent cases section' do 
    it 'should not let you add urgent cases to call list' do 
      within :css, '#urgent_pregnancies_content' do
        assert has_text? @patient.name
        refute has_link? 'Add'
      end
    end

    it 'should not let you remove urgent cases' do 
      within :css, '#urgent_pregnancies_content' do
        assert has_text? @patient.name
        refute has_link? 'Remove'
      end
    end
  end
end
