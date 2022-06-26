require 'application_system_test_case'

# Test behavior around shared cases list
class SharedCasesTest < ApplicationSystemTestCase
  before do
    @patient = create :patient, name: 'Susan Everyteen', shared_flag: true
    @user = create :user
    log_in_as @user
  end

  describe 'shared cases section' do
    it 'should not let you add shared cases to call list' do
      within :css, '#shared_cases_content' do
        assert has_text? @patient.name
        refute has_link? 'Add'
      end
    end

    it 'should not let you remove shared cases' do
      within :css, '#shared_cases_content' do
        assert has_text? @patient.name
        refute has_link? 'Remove'
      end
    end
  end
end
