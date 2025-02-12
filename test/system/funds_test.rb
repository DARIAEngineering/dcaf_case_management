require 'application_system_test_case'

class FundsTest < ApplicationSystemTestCase
  before do
    create :line
    @user = create :user, role: :admin
    log_in_as @user
    @fund = Fund.first
  end

  test 'visiting the fund' do
    visit fund_url(@fund)
    puts @fund.as_json
    assert_selector 'h1', text: @fund.name
  end

  test 'updating the fund' do
    visit fund_url(@fund)
    click_on 'Edit', match: :first
    fill_in 'Phone', with: '555-555-5555'
    click_away_from_field
    wait_for_ajax
    click_on 'Save changes'
    assert_text 'Successfully updated fund details.'
  end
end
