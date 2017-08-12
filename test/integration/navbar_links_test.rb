require 'application_system_test_case'

class NavbarLinksTest < ApplicationSystemTestCase
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
    describe 'admin view' do
      before { click_link 'Admin' }

      it 'should display User management link' do
        assert has_link? 'User Management', href: users_path
      end

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

    describe 'data volunteer view' do
      before do
        sign_out
        @user2 = create :user, role: :data_volunteer
        log_in_as @user2
        visit authenticated_root_path
        click_link 'Admin tools'
      end

      it 'should not display the new user link' do
        refute has_link? 'User Management'
      end

      it 'should not display the Clinic Management link' do
        refute has_link? 'Clinic Management'
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

    describe 'case manager view' do
      before do
        sign_out
        @user3 = create :user, role: :cm
        log_in_as @user3
        visit authenticated_root_path
      end

      it 'should not display an admin link' do
        refute has_link? 'Admin tools'
      end
    end
  end
end
