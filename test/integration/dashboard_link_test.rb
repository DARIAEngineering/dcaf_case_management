require 'test_helper'

class DashboardLinkTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    log_in_as @user
  end

  describe 'visiting the dashboard' do
    it 'should not display the dashboard link' do
      visit authenticated_root_path
      refute has_link? 'Dashboard', href: authenticated_root_path
    end
  end

  describe 'visiting a page other than the dashboard' do
    before do
      @patient = create :patient
      @pregnancy = create :pregnancy, patient: @patient
      visit edit_pregnancy_path(@pregnancy)
    end

    it 'should display the dashboard link' do
      assert has_link? 'Dashboard', href: authenticated_root_path
    end

    it 'should direct the user to the dashboard' do
      click_link 'Dashboard'
      assert_equal current_path, authenticated_root_path
      refute has_link? 'Dashboard', href: authenticated_root_path
    end
  end
end
