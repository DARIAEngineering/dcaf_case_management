require 'test_helper'

class ShowPregnancyInformationTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @user = create :user
    log_in_as @user
    visit edit_pregnancy_path(@pregnancy)
  end

  after do
    Capybara.use_default_driver
  end

  describe 'clicking between sections to see information' do
    it 'should show the patient dashboard on open' do
      within :css, '#patient_dashboard' do
        assert has_text? 'First and last name'
        assert has_text? 'LMP at intake'
        assert has_text? 'Appointment date'
        assert has_text? 'Phone number'
        assert has_text? 'Status'
      end
    end

    it 'should have everything in the sidebar' do
      within :css, '#menu' do
        assert has_link? 'Abortion Information'
        assert has_link? 'Patient Information'
        assert has_link? 'Change Log'
        assert has_link? 'Call Log'
        assert has_link? 'Notes'
      end
    end

    it 'should show abortion information on open' do
      within :css, '#sections' do
        assert has_text? 'Abortion information'
        assert has_text? 'Clinic details'
        assert has_text? 'Cost details'
      end
    end

    it 'should let you click to patient information' do
      click_link 'Patient Information'
      within :css, '#sections' do
        refute has_text? 'Abortion information'
        assert has_text? 'Patient information'
      end
    end

    it 'should let you click to the change log' do
      click_link 'Change Log'
      within :css, '#sections' do
        refute has_text? 'Abortion information'
        assert has_text? 'Patient history'
      end
    end

    it 'should let you click to the call log' do
      click_link 'Call Log'
      within :css, '#sections' do
        refute has_text? 'Abortion information'
        assert has_text? 'Call Log'
      end
    end

    it 'should let you click to the notes' do
      click_link 'Notes'
      within :css, '#sections' do
        refute has_text? 'Abortion information'
        assert has_text? 'Notes'
      end
    end

    it 'should let you click back to abortion information' do
      click_link 'Notes'
      within(:css, '#sections') { refute has_text? 'Abortion information' }
      click_link 'Abortion Information'
      within(:css, '#sections') { assert has_text? 'Abortion information' }
    end
  end
end
