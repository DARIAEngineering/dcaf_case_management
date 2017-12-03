require 'application_system_test_case'

# Does loading the app work?
class EverythingOkAlarmTest < ApplicationSystemTestCase
  # confirm that the app is loading and that the main page is clean
  it 'SHOULD SOUND THIS ALARM WHEN EVERYTHING IS OKAY' do
    get '/'
    assert_response :redirect
  end
end
