require 'test_helper'

class SubmitPledgeTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @pregnancy = create :pregnancy
    log_in_as @user
    visit edit_pregnancy_path @pregnancy
    has_text? 'First and last name'
  end

  after do
    Capybara.use_default_driver
  end

  describe 'submitting a pledge' do
    it 'should let you mark a pledge submitted' do
      find('#submit-pledge-button').click
      # click_link 'Submit pledge'
      assert has_text? 'Confirm the following information is correct'
      find('#submit-pledge-to-p2').click

      assert has_text? 'Review this preview of your pledge'
      find('#submit-pledge-to-p3').click

      assert has_text? 'Awesome, you generated a DCAF'
      check 'I sent the pledge'
      find('#submit-pledge-finish').click

      click_link 'Dashboard'
      visit edit_pregnancy_path @pregnancy
      assert has_text? 'Pledge sent'
    end
  end

  # describe 'unsubmitting a pledge' do

  # end
  # test "the truth" do
  #   assert true
  # end
end
