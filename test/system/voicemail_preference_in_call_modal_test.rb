require 'application_system_test_case'

# Confirm display behavior around whether a patient should receive VMs
class VoicemailPreferenceInCallModalTest < ApplicationSystemTestCase
  extend Minitest::OptionalRetry

  before do
    @patient = create :patient, name: 'Susan Everyteen'
    @user = create :user
    log_in_as @user
  end

  # this test is flaky
  describe 'different voicemail preferences and links' do
    describe 'no voicemail' do
      before do
        @patient.voicemail_preference = 'no'
        @patient.save
        open_call_modal_for @patient
      end

      it 'should have warning text and no link' do
        assert has_text? 'Do not leave this patient a voicemail'
        refute has_link? 'I left a voicemail for the patient'
      end
    end

    describe 'voicemail ok but no id' do
      before do
        open_call_modal_for @patient
      end

      it 'should have warning text and a link' do
        assert has_text? "Voicemail OK; Do not identify as #{ActsAsTenant.current_tenant.name}"
        assert has_link? 'I left a voicemail for the patient'
      end
    end

    describe 'voicemail ok' do
      before do
        @patient.voicemail_preference = 'yes'
        @patient.save
        open_call_modal_for @patient
      end

      it 'should have goahead text and a link' do
        assert has_text? "Voicemail OK; Okay to identify as #{ActsAsTenant.current_tenant.name}"
        assert has_link? 'I left a voicemail for the patient'
      end
    end

    describe 'custom voicemail' do
        before do
            create_voicemail_config
            @patient.voicemail_preference = 'Use Codename'
            @patient.save
            open_call_modal_for @patient
        end

        it 'should have custom text and link' do
            assert has_text? 'Use Codename'
            assert has_link? 'I left a voicemail for the patient'
        end
    end
  end

  private

  def open_call_modal_for(patient)
    fill_in 'search', with: patient.name
    click_button 'Search'
    find("a.call-#{patient.primary_phone_display}").click
  end
end
