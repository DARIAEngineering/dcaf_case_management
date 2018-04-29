require 'test_helper'

class ArchivedPatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'

    @patient.calls.create attributes_for(:call, created_by: @user, status: 'Reached patient')
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

  describe 'Archiving Convert method' do
    before do
      @clinic = create :clinic
      @patient4 = create :patient, primary_phone: '222-222-3336',
                                   other_phone: '222-222-4441',
                                   line: 'DC',
                                   clinic: @clinic,
                                   city: 'Washington',
                                   race_ethnicity: 'Asian',
                                   initial_call_date: 16.days.ago,
                                   appointment_date: 6.days.ago
      @patient4.calls.create attributes_for(:call, created_by: @user, status: "Couldn't reach patient")
      @patient4.calls.create attributes_for(:call, created_by: @user, status: 'Reached patient')
      @patient4.update fulfillment: {
                                  fulfilled: true,
                                  date_of_check: 3.days.ago,
                                  procedure_date: 6.days.ago,
                                  check_number: '123'
                                }
      @patient4.external_pledges.create source: 'Baltimore Abortion Fund',
                                     amount: 100,
                                     created_by: @user
      @patient4.save!
      @archived_patient = ArchivedPatient.convert_patient(@patient4)
      @archived_patient.save!
    end

    it 'Patient and Archive Patient data should match' do
      assert_equal @archived_patient.line, @patient4.line
      assert_equal @archived_patient.city, @patient4.city
      assert_equal @archived_patient.race_ethnicity, @patient4.race_ethnicity
      assert_equal @archived_patient.appointment_date,
                   @patient4.appointment_date
    end
    it 'Patient and Archive Patient share a clinic' do
      assert_equal @archived_patient.clinic_id, @patient4.clinic_id
    end
    it 'Patient and Archive Patient subobject data should match' do
      assert_equal @archived_patient.calls.count, @patient4.calls.count
      assert_equal @archived_patient.fulfillment.date_of_check,
                   @patient4.fulfillment.date_of_check
      assert_equal @archived_patient.external_pledges.first.source,
                   @patient4.external_pledges.first.source
    end
    it 'Patient and Archive Patient subobjects should be distinct' do
      assert_not_equal @archived_patient.calls.first.id,
                       @patient4.calls.first.id
      assert_not_equal @archived_patient.fulfillment.id,
                       @patient4.fulfillment.id
      assert_not_equal @archived_patient.external_pledges.first.id,
                       @patient4.external_pledges.first.id
    end
  end

  describe 'Archiving Fulfilled and Dropped Off Patients' do
    before do
      @clinic = create :clinic
      @patient_old = create :patient, primary_phone: '222-222-3333',
                                      other_phone: '222-222-4444',
                                      initial_call_date: 600.days.ago
      @patient_fulfilled = create :patient, primary_phone: '222-222-3334',
                                   other_phone: '222-222-4443',
                                   initial_call_date: 310.days.ago
      @patient_fulfilled.update fulfillment: {
                                  fulfilled: true,
                                  date_of_check: 300.days.ago,
                                  procedure_date: 290.days.ago,
                                  check_number: '123'
                                }
      @patient_fulfilled.save!

      @patient_fulfilled2 = create :patient, primary_phone: '222-212-3334',
                                   other_phone: '222-222-4443',
                                   initial_call_date: 310.days.ago
      @patient_fulfilled2.update fulfillment: {
                                  fulfilled: true,
                                  date_of_check: 300.days.ago,
                                  procedure_date: 290.days.ago,
                                  check_number: '123'
                                }
      @patient_fulfilled2.save!
    end

    it 'Should archive the old, dropoff patient' do
       assert_difference 'ArchivedPatient.all.count', 1 do
        assert_difference 'Patient.all.count', -1 do
          ArchivedPatient.archive_dropped_off_patients!
        end
       end
    end

    it 'Should archive the fulfilled patients' do
       assert_difference 'ArchivedPatient.all.count', 2 do
         assert_difference 'Patient.all.count', -2 do
           ArchivedPatient.archive_fulfilled_patients!
         end
       end
    end
  end


end
