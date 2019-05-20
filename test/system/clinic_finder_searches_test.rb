require 'application_system_test_case'

# System test for using the clinic finder form.
class ClinicFinderSearchesTest < ApplicationSystemTestCase
  # Commented out because mocking doesn't seem to work in systemtests yet.
  # before do
  #   @clinic_struct = OpenStruct.new create(:clinic).attributes
  #   @clinic_struct.distance = 30
  #   @clinic_finder_mock = Minitest::Mock.new
  #   @clinic_finder_mock.expect(:locate_nearest_clinics,
  #                              [@clinic_struct],
  #                              ['12345'])

  #   @patient = create :patient

  #   log_in_as create(:user)
  # end

  # describe 'using the clinic finder search form' do
  #   it 'should let you search' do
  #     visit edit_patient_path(@patient)

  #     click_link 'Abortion Information'
  #     find('.clinic-finder-expand').click

  #     fill_in "Patient's ZIP code", with: '12345'
  #     click_button 'Search clinics'
  #     wait_for_ajax

  #     within :css, '#clinic-finder-results' do
  #       assert has_text? @clinic_struct.name
  #     end
  #   end
  # end
end
