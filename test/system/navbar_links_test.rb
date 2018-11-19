require 'application_system_test_case'

class NavbarLinksTest < ApplicationSystemTestCase
  before do
    @user = create :user, role: :admin
    log_in_as @user
  end

  describe 'user dropdown' do
    before { click_link @user.name }
    it 'should display the profile link' do
      assert has_link? I18n.t('navigation.user_tools.profile'), href: edit_user_registration_path
    end
  end

  describe 'admin dropdown' do
    describe 'admin view' do
      before { click_link 'Admin' }

      it 'should display User management link' do
        assert has_link? I18n.t('navigation.admin_tools.user_management'), href: users_path
      end

      it 'should display the Clinic Management link' do
        assert has_link? I18n.t('navigation.admin_tools.clinic_management'), href: clinics_path
      end

      it 'should display the Config Management link' do
        assert has_link? I18n.t('navigation.admin_tools.config_management'), href: configs_path
      end

      it 'should display the Accounting link' do
        assert has_link? I18n.t('navigation.admin_tools.accounting'), href: accountants_path
      end

      it 'should display the Reporting link' do
        assert has_link? I18n.t('navigation.admin_tools.reporting'), href: reports_path
      end

      it 'should display the export link' do
        assert has_link? I18n.t('navigation.admin_tools.export'), href: patients_path(format: :csv)
      end
    end

    describe 'data volunteer view' do
      before do
        sign_out
        @user2 = create :user, role: :data_volunteer
        log_in_as @user2
        visit authenticated_root_path
        click_link I18n.t('navigation.admin_tools.label')
      end

      it 'should not display the new user link' do
        refute has_link? I18n.t('navigation.admin_tools.user_management')
      end

      it 'should not display the Clinic Management link' do
        refute has_link? I18n.t('navigation.admin_tools.clinic_management')
      end

      it 'should not display the Config Management link' do
        refute has_link? I18n.t('navigation.admin_tools.config_management')
      end

      it 'should display the Accounting link' do
        assert has_link? I18n.t('navigation.admin_tools.accounting'), href: accountants_path
      end

      it 'should display the Reporting link' do
        assert has_link? I18n.t('navigation.admin_tools.reporting'), href: reports_path
      end

      it 'should display the export link' do
        assert has_link? I18n.t('navigation.admin_tools.export'), href: patients_path(format: :csv)
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
        refute has_link? I18n.t('navigation.admin_tools.label')
      end
    end
  end
end
