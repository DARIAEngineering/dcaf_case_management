require 'test_helper'

class NavbarLinksTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    log_in_as @user
  end

  describe 'link to dashboard' do
    describe 'visiting the dashboard' do
      it 'should not display the dashboard link' do
        visit authenticated_root_path
        wait_for_element 'Sign out'
      end
    end

    describe 'visiting a page other than the dashboard' do
      before do
        @patient = create :patient
        @pregnancy = create :pregnancy, patient: @patient
        visit edit_patient_path(@patient)
        wait_for_element 'Patient information'
      end

      it 'should display the dashboard link' do
        assert has_link? 'Dashboard', href: authenticated_root_path
      end

      it 'should direct the user to the dashboard' do
        find('a', text: 'Dashboard').click
        wait_for_element 'Build your call list'
        assert_equal current_path, authenticated_root_path
        refute has_link? 'Dashboard', href: authenticated_root_path
      end
    end
  end

  describe 'additional resources link' do
    it 'should display if env var is set' do
      ENV['CM_RESOURCES_URL'] = 'www.google.com'
      visit authenticated_root_path
      assert has_link? 'CM Resources', href: 'www.google.com'
    end

    it 'should not display if env var is not set' do
      ENV['CM_RESOURCES_URL'] = nil
      visit authenticated_root_path
      refute has_link? 'CM Resources'
    end
  end
end
