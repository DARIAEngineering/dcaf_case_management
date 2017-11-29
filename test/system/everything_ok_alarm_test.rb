require 'application_system_test_case'

class EverythingOkAlarmTest < ApplicationSystemTestCase
  # confirm that the app is loading and that the main page is clean
  it 'SHOULD SOUND THIS ALARM WHEN EVERYTHING IS OKAY' do
    visit root_path
    assert_selector "h3", text: "Sign in"
  end
end
