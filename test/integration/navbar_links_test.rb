require 'test_helper'

class NavbarLinksTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: :admin
    log_in_as @user
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

  describe 'user dropdown' do
    before { click_link @user.name }
    it 'should display the profile link' do
      assert has_link? 'My Profile', href: edit_user_registration_path
    end
  end

  describe 'admin dropdown' do
    before { click_link 'Admin' }
    it 'should display the Clinic Management link' do
      assert has_link? 'Clinic Management', href: clinics_path
    end

    it 'should display the Accounting link' do
      assert has_link? 'Accounting', href: accountants_path
    end

    it 'should display the Reporting link' do
      assert has_link? 'Reporting', href: reports_path
    end

    it 'should display the export link' do
      assert has_link? 'Export anonymized CSV', href: patients_path(format: :csv)
    end
  end
end
