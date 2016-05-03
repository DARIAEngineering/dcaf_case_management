require 'test_helper'

class DashboardLinkTest < ActionDispatch::IntegrationTest

  def setup
    @user = create :user
    log_in_as @user
  end

  describe 'visiting the dashboard' do
    before do
      visit authenticated_root_url
    end
    it 'should not display the dashboard link' do
      assert_not_equal '/Dashboard', authenticated_root_url
    end
  end
  
  describe 'visiting a page other than the dashboard' do
    before do
      @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      secondary_phone: '333-444-5555'
      @pregnancy = create :pregnancy, appointment_date: nil, patient: @patient
      @clinic = create :clinic, name: 'Standard Clinic', pregnancy: @pregnancy
      visit edit_pregnancy_path(@pregnancy)
    end
    it 'should display the dashboard link' do
      assert_equal '/Dashboard', authenticated_root_url
    end  
  end 
end

  
