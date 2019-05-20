require 'test_helper'

# For tooling related to using the clinicfinder gem
class ClinicfindersControllerTest < ActionDispatch::IntegrationTest
  describe 'search' do
    before do
      # Mock service
      @clinic_struct = OpenStruct.new create(:clinic).attributes
      @clinic_struct.distance = 300.30
      @clinic_finder_mock = Minitest::Mock.new
      @clinic_finder_mock.expect(:locate_nearest_clinics, [@clinic_struct], ['12345'])

      sign_in create(:user)
    end

    it 'should respond successfully' do
      ClinicFinder::Locator.stub(:new, @clinic_finder_mock) do
        post clinicfinder_search_path, params: { zip: '12345' }, xhr: true
      end
      assert_response :success
    end

    it 'should choke if there is not a zip code' do
      ClinicFinder::Locator.stub(:new, @clinic_finder_mock) do
        post clinicfinder_search_path, xhr: true
      end
      assert_response :bad_request
    end
  end
end
