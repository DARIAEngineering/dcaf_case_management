require 'test_helper'

class ArchivedPatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @user2 = create :user
    @line = create :line
    with_versioning(@user) do
      @patient = create :patient, other_phone: '111-222-3333',
                                  other_contact: 'Yolo',
                                  line: @line

      @patient.calls.create attributes_for(:call, status: :reached_patient)
      create_language_config
      @archived_patient = create :archived_patient,
                                 line: @line,
                                 initial_call_date: 200.days.ago
    end
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
  end

  describe 'The convert_patient method' do
    before do
      with_versioning(@user) do
        @clinic = create :clinic
        @patient = create :patient, primary_phone: '222-222-3336',
                                    other_phone: '222-222-4441',
                                    line: @line,
                                    clinic: @clinic,
                                    city: 'Washington',
                                    race_ethnicity: 'Asian',
                                    initial_call_date: 16.days.ago,
                                    appointment_date: 6.days.ago
        @patient.calls.create status: :couldnt_reach_patient
        @patient.external_pledges.create source: 'Friendship Abortion Fund',
                                         amount: 100
        @patient.practical_supports.create support_type: 'Metallica tickets',
                                           source: 'My mom'
        @patient.fulfillment.update fulfilled: true,
                                    updated_at: 3.days.ago,
                                    date_of_check: 3.days.ago,
                                    procedure_date: 6.days.ago,
                                    check_number: '123'
      end

      with_versioning(@user2) do
        @patient.calls.create status: :reached_patient
        @patient.external_pledges.create source: 'Metallica Abortion Fund',
                                         amount: 100
        @patient.practical_supports.create support_type: 'Louder Metallica tickets',
                    source: 'Metallica'
        @archived_patient = ArchivedPatient.convert_patient(@patient)
        @archived_patient.save!
      end
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
      # and that includes ids
      call_ids = @patient.calls.pluck('id')
      ext_pledge_ids = @patient.external_pledges.pluck('id')
      psup_ids = @patient.practical_supports.pluck('id')
      fulfillment_id = @patient.fulfillment.id
      @archived_patient.reload
      @patient.reload

      assert_equal 2, @archived_patient.calls.count
      assert_equal call_ids, @archived_patient.calls.pluck('id')
      assert_equal 0, @patient.calls.count
      assert_equal @user, @archived_patient.calls.first.created_by
      assert_equal @user2, @archived_patient.calls.last.created_by

      assert_equal fulfillment_id, @archived_patient.fulfillment.id
      assert_equal @archived_patient.fulfillment.date_of_check,
                   3.days.ago.to_date
      assert_nil @patient.fulfillment

      assert_equal 2, @archived_patient.external_pledges.count
      assert_equal ext_pledge_ids, @archived_patient.external_pledges.pluck('id')
      assert_equal 0, @patient.external_pledges.count
      assert_equal @user, @archived_patient.external_pledges.first.created_by
      assert_equal @user2, @archived_patient.external_pledges.last.created_by

      assert_equal 2, @archived_patient.practical_supports.count
      assert_equal psup_ids, @archived_patient.practical_supports.pluck('id')
      assert_equal 0, @patient.practical_supports.count
      assert_equal @user, @archived_patient.practical_supports.first.created_by
      assert_equal @user2, @archived_patient.practical_supports.last.created_by
    end
  end

  describe 'archive_audited_patients' do
    before do
      @patient_audited = create :patient, primary_phone: '222-222-3333',
                                      other_phone: '222-222-4444',
                                      initial_call_date: 30.days.ago,
                                      line: @line
      @patient_audited.fulfillment.update audited: true

      @patient_unaudited = create :patient, primary_phone: '564-222-3333',
                                      other_phone: '222-222-9074',
                                      initial_call_date: 120.days.ago,
                                      line: @line
    end

    it 'should not convert thirty day old, audited patient to archived patient' do
      assert_difference 'ArchivedPatient.all.count', 0 do
        assert_difference 'Patient.all.count', 0 do
          ArchivedPatient.archive_eligible_patients!
        end
      end
    end
    it 'should convert four months old, audited patient to archived patient' do
      @patient_audited.update initial_call_date: 120.days.ago
      @patient_audited.save!
      assert_difference 'ArchivedPatient.all.count', 1 do
        assert_difference 'Patient.all.count', -1 do
          ArchivedPatient.archive_eligible_patients!
        end
       end
    end
  end

  describe 'archive_unaudited_year_ago_patients' do
    before do
      @patient_old_unaudited = create :patient, primary_phone: '564-222-3333',
                                      other_phone: '222-222-9074',
                                      initial_call_date: 370.days.ago,
                                      line: @line
      @patient_old_unaudited.fulfillment.update audited: false
      @patient_old_unaudited.save!
    end

    it 'should convert year+ old unaudited patient to archived patient' do
       assert_difference 'ArchivedPatient.all.count', 1 do
        assert_difference 'Patient.all.count', -1 do
          ArchivedPatient.archive_eligible_patients!
        end
       end
    end
  end
end
