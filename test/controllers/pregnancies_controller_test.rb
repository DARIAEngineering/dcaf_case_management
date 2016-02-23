require 'test_helper'

class PregnanciesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    sign_in @user
  end
end
