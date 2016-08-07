require 'test_helper'

class VoicemailPreferenceInCallModalTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @user = create :user
    log_in_as @user
  end

  after { Capybara.use_default_driver }

  describe 'different voicemail preferences and links' do
    describe 'no voicemail' do
      before do
        @pregnancy.voicemail_preference = :no
        @pregnancy.save
        open_call_modal_for @pregnancy
      end

      it 'should have warning text and no link' do
        assert has_text? 'Do not leave this patient a voicemail'
        refute has_link? 'I left a voicemail for the patient'
      end
    end

    describe 'voicemail ok but no id' do
      before do
        open_call_modal_for @pregnancy
      end

      it 'should have warning text and a link' do
        assert has_text? 'Voicemail OK; Do not identify as DCAF'
        assert has_link? 'I left a voicemail for the patient'
      end
    end

    describe 'voicemail ok' do
      before do
        @pregnancy.voicemail_preference = :yes
        @pregnancy.save
        open_call_modal_for @pregnancy
      end

      it 'should have goahead text and a link' do
        assert has_text? 'Voicemail OK; Okay to identify as DCAF'
        assert has_link? 'I left a voicemail for the patient'
      end
    end
  end

  private

  def open_call_modal_for(pregnancy)
    fill_in 'search', with: pregnancy.patient.name
    click_button 'Search'
    find("a[href='#call-#{pregnancy.patient.primary_phone_display}']").click
  end
end
