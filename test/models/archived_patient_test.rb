require 'test_helper'

class ArchivedPatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'

    @patient.calls.create attributes_for(:call, created_by: @user, status: 'Reached patient')
    create_language_config
    @archived_patient = create :archived_patient, line: 'DC',
                                initial_call_date: 200.days.ago,
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

  describe 'archive_audited_patients' do
    before do
      @patient_audited = create :patient, primary_phone: '222-222-3333',
                                      other_phone: '222-222-4444',
                                      initial_call_date: 30.days.ago
      @patient_audited.update fulfillment: { audited: true }
      @patient_audited.save!

      @patient_unaudited = create :patient, primary_phone: '564-222-3333',
                                      other_phone: '222-222-9074',
                                      initial_call_date: 120.days.ago
    end

    it 'should not convert thirty day old, audited patient to archive patient' do
      assert_difference 'ArchivedPatient.all.count', 0 do
        assert_difference 'Patient.all.count', 0 do
          ArchivedPatient.archive_todays_patients!
        end
      end
    end
    it 'should convert four months old, audited patient to archive patient' do
      @patient_audited.update initial_call_date: 120.days.ago
      @patient_audited.save!
      assert_difference 'ArchivedPatient.all.count', 1 do
        assert_difference 'Patient.all.count', -1 do
          ArchivedPatient.archive_todays_patients!
        end
       end
    end
  end

  describe 'archive_unaudited_year_ago_patients' do
    before do
      @patient_old_unaudited = create :patient, primary_phone: '564-222-3333',
                                      other_phone: '222-222-9074',
                                      initial_call_date: 370.days.ago
      @patient_old_unaudited.update fulfillment: { audited: false }
      @patient_old_unaudited.save!
    end

    it 'should convert 2 year+ old unaudited patient to archive patient' do
       assert_difference 'ArchivedPatient.all.count', 1 do
        assert_difference 'Patient.all.count', -1 do
          ArchivedPatient.archive_todays_patients!
        end
       end
    end
  end

end
