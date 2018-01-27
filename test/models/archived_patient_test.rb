require 'test_helper'

class ArchivedPatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'

    @call = create :call, patient: @patient,
                          status: 'Reached patient'
    create_language_config
    @archived_patient = create :archived_patient, line: 'DC',
                                initial_call_date: 400.days.ago,
                                created_by_id: @user.id
  end

  describe 'validations' do
    it 'should build' do
      assert @archived_patient.valid?
    end

    it 'requires a line' do
      @archived_patient.line = nil
      refute @archived_patient.valid?
    end

    it 'requires an initial call date' do
      @archived_patient.initial_call_date = nil
      refute @archived_patient.valid?
    end

    it 'requires a logged creating user' do
      @archived_patient.created_by_id = nil
      refute @archived_patient.valid?
    end
  end


  describe 'Archiving Methods' do
    before do
      @patient_old = create :patient, primary_phone: '222-222-3333',
                                      other_phone: '222-222-4444',
                                      initial_call_date: 600.days.ago
      @patient_fulfilled = create :patient, primary_phone: '222-222-3334',
                                   other_phone: '222-222-4443'
      @patient_fulfilled2 = create :patient, primary_phone: '222-212-3334',
                                   other_phone: '222-222-4443'
      @patient4 = create :patient, primary_phone: '222-222-3336',
                                   other_phone: '222-222-4441',
                                   line: 'DC',
                                   city: 'Washington',
                                   race_ethnicity: 'Asian',
                                   initial_call_date: 16.days.ago,
                                   appointment_date: 6.days.ago
    end

    it 'Should create an archive copy of a patient' do
      @archived_patient = ArchivedPatient.convert_patient(@patient4)
      @archived_patient.save!
      assert_equal @archived_patient.line, @patient.line
      assert_equal @archived_patient.city, @patient.city
      assert_equal @archived_patient.race_ethnicity, @patient.race_ethnicity
      assert_equal @archived_patient.appointment_date, @patient.appointment_date
    end

    it 'Should archive the old patient' do
       assert_difference 'ArchivedPatient.all.count', 1 do
         ArchivedPatient.process_dropped_off_patients
       end
       assert_difference 'Patient.all.count', -1 do
         ArchivedPatient.process_dropped_off_patients
       end
    end

    it 'Should archive the dropoff patient' do
       assert_difference 'ArchivedPatient.all.count', 2 do
         ArchivedPatient.process_dropped_off_patients
       end
       assert_difference 'Patient.all.count', -2 do
         ArchivedPatient.process_dropped_off_patients
       end
    end
  end


end
