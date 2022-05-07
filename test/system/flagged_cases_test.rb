require 'application_system_test_case'

# Test behavior around flagged cases list
class FlaggedCasesTest < ApplicationSystemTestCase
  before do
    @patient = create :patient, name: 'Susan Everyteen', flagged: true
    @user = create :user
    log_in_as @user
  end

  describe 'flagged cases section' do
    it 'should not let you add flagged cases to call list' do
      within :css, '#flagged_cases_content' do
        assert has_text? @patient.name
        refute has_link? 'Add'
      end
    end

    it 'should not let you remove flagged cases' do
      within :css, '#flagged_cases_content' do
        assert has_text? @patient.name
        refute has_link? 'Remove'
      end
    end
  end
end
