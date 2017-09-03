require 'test_helper'

class FilterNafClinicsTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user, role: :cm
    @naf_clinic = create :clinic, name: 'NAF Accepted', accepts_naf: true
    @nonnaf_clinic = create :clinic, name: 'No NAF here', accepts_naf: false
    @patient = create :patient
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
    click_link 'Abortion Information'
  end

  describe 'filtering to just NAF clinics' do
    it 'should filter to only NAF clinics when box is checked' do
      assert has_select? 'patient_clinic_id', options: ['', @naf_clinic.name,
                                                             @nonnaf_clinic.name]

      check 'naf_filter'
      sleep 1
      options_with_filter = find('#patient_clinic_id').all('option')
                                                      .map { |opt| { name: opt.text, disabled: opt['disabled'] } }

      assert options_with_filter.find { |x| x[:name] == @nonnaf_clinic.name }[:disabled] == true
      assert options_with_filter.find { |x| x[:name] == @naf_clinic.name }[:disabled] == false

      # try to select and watch it not work
      select @nonnaf_clinic.name, from: 'patient_clinic_id'
      assert_equal '', find('#patient_clinic_id').value
    end
  end
end
