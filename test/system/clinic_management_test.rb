require 'application_system_test_case'

# Test workflows around administering lists of clinics a fund works with
class ClinicManagementTest < ApplicationSystemTestCase
  before do
    @clinic = create :clinic, accepts_naf: true,
                              accepts_medicaid: true

    @user = create :user, role: 'admin'
    @nonadmin = create :user, role: 'cm'
    log_in_as @user
    visit clinics_path
  end

  describe 'viewing clinic info' do
    before { visit clinics_path }

    it 'should have existing clinics in the table' do
      within :css, '#clinics_table' do
        assert has_text? @clinic.name
      end

      find("#clinic-toggle-#{@clinic.id}").click
      wait_for_ajax
      within :css, "clinic-#{@clinic.id}-detail" do
        assert has_text? 'Accepts Medicaid?'
        assert has_text? 'Yes'
      end
    end
  end

  describe 'adding a clinic' do
    before { click_link 'Add a new clinic' }

    it 'should add a clinic' do
      new_clinic_name = 'Games Done Quick Throw a Benefit for DCAF'
      fill_in 'Name', with: new_clinic_name
      fill_in 'Street address', with: '123 Fake Street'
      fill_in 'City', with: 'Yolo'
      fill_in 'State', with: 'TX'
      fill_in 'Zip', with: '12345'
      fill_in 'Phone', with: '281-330-8004'
      fill_in 'Fax', with: '222-333-4444'
      check 'Accepts NAF'
      check 'Accepts Medicaid'
      fill_in 'Gestational limit (in days)', with: '30'
      (5..30).each do |i|
        fill_in "Costs #{i}wks", with: i
      end
      click_button 'Add clinic'

      assert has_text? "#{new_clinic_name} created!"
      within :css, '#clinics_table' do
        assert has_text? new_clinic_name
      end
      click_link new_clinic_name

      assert has_field? 'Name', with: new_clinic_name
      assert has_field? 'Street address', with: '123 Fake Street'
      assert has_field? 'City', with: 'Yolo'
      assert has_field? 'State', with: 'TX'
      assert has_field? 'Zip', with: '12345'
      assert has_field? 'Phone', with: '281-330-8004'
      assert has_field? 'Fax', with: '222-333-4444'
      assert has_checked_field? 'Accepts NAF'
      assert has_checked_field? 'Accepts Medicaid'
      assert ha_field? 'Gestational limit (in days)', with: '30'
      (5..30).each do |i|
        assert has_field? "Costs #{i}wks", with: i
      end
    end

    it 'should prevent creation if the payload is bad' do
    end
  end

  describe 'updating a clinic' do

  end

  describe 'disabling a clinic' do

  end
end
