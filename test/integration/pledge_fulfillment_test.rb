require 'test_helper'

class PledgeFulfillmentTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user, role: 'cm'
    @admin = create :user, role: 'admin'
    @patient = create :patient
    @pregnancy = create :pregnancy, pledge_sent: false
    log_in_as @user
    visit edit_patient_path @patient
  end

  after do
    Capybara.use_default_driver
  end
  
  log_in_as @user
  
  describe 'visiting the edit patient view as a CM' do
    it 'should not show the pledge fulfillment link to a CM' do
      refute has_link? 'Pledge Fulfillment'
    end
  end
  
  sign_out
  log_in_as @admin
  
  describe 'visiting the edit patient view as an admin' do
    it 'should show text with no link' do
      assert has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end
  end
  
  before do
    @pregnancy.pledge_sent = true 
  end
  
  describe 'visiting the edit patient view as an admin after the pledge is sent' do
    it 'should show text with no link' do
      assert has_link? 'Pledge Fulfillment'
      click_link 'Pledge Fulfillment'
      assert has_text? 'Procedure Date'
      assert has_text? 'Check #'
    end
  end
end