require "application_system_test_case"

class FundsTest < ApplicationSystemTestCase
  setup do
    @fund = funds(:one)
  end

  test "visiting the index" do
    visit funds_url
    assert_selector "h1", text: "Funds"
  end

  test "should create fund" do
    visit funds_url
    click_on "New fund"

    click_on "Create Fund"

    assert_text "Fund was successfully created"
    click_on "Back"
  end

  test "should update Fund" do
    visit fund_url(@fund)
    click_on "Edit this fund", match: :first

    click_on "Update Fund"

    assert_text "Fund was successfully updated"
    click_on "Back"
  end

  test "should destroy Fund" do
    visit fund_url(@fund)
    click_on "Destroy this fund", match: :first

    assert_text "Fund was successfully destroyed"
  end
end
