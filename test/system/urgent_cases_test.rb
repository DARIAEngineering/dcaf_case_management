require 'application_system_test_case'

# Test behavior around urgent cases list
class UrgentCasesTest < ApplicationSystemTestCase
  before do
    @patient = create :patient, name: 'Susan Everyteen', urgent_flag: true
    @user = create :user
    log_in_as @user
  end

  describe 'urgent cases section' do
    it 'should not let you add urgent cases to call list' do
      within :css, '#urgent_patients_content' do
        assert has_text? @patient.name
        refute has_link? 'Add'
      end
    end

    it 'should not let you remove urgent cases' do
      within :css, '#urgent_patients_content' do
        assert has_text? @patient.name
        refute has_link? 'Remove'
      end
    end
  end
end
