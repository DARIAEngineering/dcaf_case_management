require 'test_helper'

class CallListTest < ActionDispatch::IntegrationTest
  before do
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @patient_2 = create :patient, name: 'Thorny', primary_phone: '123-123-1235'
    @pregnancy_2 = create :pregnancy, patient: @patient_2
    @user = create :user
    log_in_as @user
    search_for @patient.name
  end

  describe 'populating call list' do
    it 'should add people to the call list roll' do
      find('a', text: 'Add').click


    end
  end

  describe 'call list persistence between multiple users' do
  end

  describe 'completed calls feature' do
  end

  private

  def search_for(patient_name)
    fill_in 'search', with: patient_name
    click_button 'Search'
  end
end
