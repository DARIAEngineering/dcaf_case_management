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

  describe 'The convert_patient method' do
    before do
      @clinic = create :clinic
      @patient = create :patient, primary_phone: '222-222-3336',
                                   other_phone: '222-222-4441',
                                   line: 'DC',
                                   clinic: @clinic,
                                   city: 'Washington',
                                   race_ethnicity: 'Asian',
                                   initial_call_date: 16.days.ago,
                                   appointment_date: 6.days.ago
      @patient.calls.create attributes_for(:call, created_by: @user, status: "Couldn't reach patient")
      @patient.calls.create attributes_for(:call, created_by: @user, status: 'Reached patient')
      @patient.update fulfillment: {
                                  fulfilled: true,
                                  updated_at: 3.days.ago,
                                  date_of_check: 3.days.ago,
                                  procedure_date: 6.days.ago,
                                  check_number: '123'
                                }
      @patient.external_pledges.create source: 'Baltimore Abortion Fund',
                                     amount: 100,
                                     created_by: @user
      @patient.save!
      @archived_patient = ArchivedPatient.convert_patient(@patient)
      @archived_patient.save!
    end

    it 'should have matching data for Patient and Archive Patient' do
      assert_equal @archived_patient.line, @patient.line
      assert_equal @archived_patient.city, @patient.city
      assert_equal @archived_patient.race_ethnicity, @patient.race_ethnicity
      assert_equal @archived_patient.appointment_date,
                   @patient.appointment_date
    end
    it 'should have a shared clinic for Patient and Archive Patient' do
      assert_equal @archived_patient.clinic_id, @patient.clinic_id
    end
    it 'should have matching subobject data Patient and Archive Patient' do
      assert_equal @archived_patient.calls.count, @patient.calls.count
      assert_equal @archived_patient.fulfillment.date_of_check,
                   @patient.fulfillment.date_of_check
      assert_equal @archived_patient.external_pledges.first.source,
                   @patient.external_pledges.first.source
    end
    it 'should have distinct subobjects for Patient and Archive Patient' do
      assert_not_equal @archived_patient.calls.first.id,
                       @patient.calls.first.id
      assert_not_equal @archived_patient.fulfillment.id,
                       @patient.fulfillment.id
      assert_not_equal @archived_patient.external_pledges.first.id,
                       @patient.external_pledges.first.id
    end
  end

  describe 'archive_dropped_off_patients' do
    before do
      @patient_old = create :patient, primary_phone: '222-222-3333',
                                      other_phone: '222-222-4444',
                                      initial_call_date: 600.days.ago
    end

    it 'should convert dropped off patient to archive patient' do
       assert_difference 'ArchivedPatient.all.count', 1 do
        assert_difference 'Patient.all.count', -1 do
          ArchivedPatient.archive_dropped_off_patients!
        end
       end
    end
  end


  describe 'archive_fulfilled_patients' do
    before do
      @patient_fulfilled = create :patient, primary_phone: '222-222-3334',
                                   other_phone: '222-222-4443',
                                   initial_call_date: 310.days.ago
      @patient_fulfilled.update fulfillment: {
                                  fulfilled: true,
                                  date_of_check: 300.days.ago,
                                  updated_at: 290.days.ago,
                                  procedure_date: 290.days.ago,
                                  check_number: '123'
                                }
      @patient_fulfilled.save!

      @patient_fulfilled2 = create :patient, primary_phone: '222-212-3334',
                                   other_phone: '222-222-4443',
                                   initial_call_date: 310.days.ago
      @patient_fulfilled2.update fulfillment: {
                                  fulfilled: true,
                                  updated_at: 291.days.ago,
                                  date_of_check: 300.days.ago,
                                  procedure_date: 290.days.ago,
                                  check_number: '123'
                                }
      @patient_fulfilled2.save!
    end

    it 'should convert fulfilled patients to archive patients' do
       assert_difference 'ArchivedPatient.all.count', 2 do
         assert_difference 'Patient.all.count', -2 do
           ArchivedPatient.archive_fulfilled_patients!
         end
       end
    end
  end


end
