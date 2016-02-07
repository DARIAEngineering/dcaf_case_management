require 'test_helper'

class EverythingOkAlarmTest < ActionDispatch::IntegrationTest
  # confirm that the app is loading and that the main page is clean
  it "SHOULD SOUND THIS ALARM WHEN EVERYTHING IS OKAY" do 
    get '/'
    assert_response :redirect
  end
end
