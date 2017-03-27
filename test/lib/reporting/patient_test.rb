require 'test_helper'

class ReportingPatientTest < ActiveSupport::TestCase
  before do
    @user = create :user

    # we'll create five patients with reached calls this month
    (1..5).each do |patient_number|
      patient = create(
        :patient,
        line: 'VA',
        other_phone: '111-222-3333',
        other_contact: 'Yolo'
      )

      # reached calls this month
      (1..5).each do |call_number|
        Timecop.freeze(Time.now - call_number.days) do
          create(
            :call,
            patient: patient,
            status: 'Reached patient'
          )
        end
      end

      # not reached calls this month
      (1..5).each do |call_number|
        Timecop.freeze(Time.now - call_number.days) do
          create(
            :call,
            patient: patient,
            status: 'Left voicemail'
          )
        end
      end
    end

    # we'll create 5 patients with calls this year
    (1..5).each do |patient_number|
      patient = create(
        :patient,
        line: 'VA',
        other_phone: '111-222-3333',
        other_contact: 'Yolo'
      )

        # calls this year
      (1..5).each do |call_number|
        Timecop.freeze(Time.now - call_number.months - call_number.days) do
          create(
            :call,
            patient: patient,
            status: 'Reached patient'
          )
        end
      end
    end
  end

  describe '.contacted_for_line' do
    it 'should return the correct amount of contacted patients for the timeframe' do
      month_num_contacted = Reporting::Patient.contacted_for_line('VA', Time.now - 1.month, Time.now)
      assert_equal 5, month_num_contacted

      year_num_contacted = Reporting::Patient.contacted_for_line('VA', Time.now - 1.year, Time.now)
      assert_equal 10, year_num_contacted
    end
  end

  describe '.new_contacted_for_line' do
    before do
      # this patient should not appear in monthly because they were contacted first 2 months ago
      # they should appear in yearly
      patient = create(
        :patient,
        line: 'VA',
        other_phone: '111-222-3333',
        other_contact: 'Yolo'
      )

      # call from 2 months ago
      Timecop.freeze(Time.now - 2.months) do
        create(
          :call,
          patient: patient,
          status: 'Reached patient'
        )
      end

      # call from now
      create(
        :call,
        patient: patient,
        status: 'Reached patient'
      )
    end
    it 'should return the correct amount of contacted patients for the first time in the timeframe' do
      month_num_contacted = Reporting::Patient.new_contacted_for_line('VA', Time.now - 1.month, Time.now)
      assert_equal 5, month_num_contacted

      year_num_contacted = Reporting::Patient.new_contacted_for_line('VA', Time.now - 1.year, Time.now)
      assert_equal 11, year_num_contacted
    end
  end

  describe '.pledges_sent_for_line' do
    before do
      patient = create(
        :patient,
        line: 'VA',
        other_phone: '111-222-3333',
        other_contact: 'Yolo',
        clinic_name: 'My special clinic',
        appointment_date: Date.today
      )

      Timecop.freeze(Time.now - 2.days) do
        creation_hash = {
          created_by: @user,
          pledge_sent: true,
          dcaf_soft_pledge: 1000
        }

        pregnancy = patient.build_pregnancy(creation_hash)
        pregnancy.save
      end

      patient2 = create(
        :patient,
        line: 'VA',
        other_phone: '111-222-3333',
        other_contact: 'Yolo',
        clinic_name: 'My special clinic',
        appointment_date: Date.today
      )

      Timecop.freeze(Time.now - 2.months) do
        creation_hash = {
          created_by: @user,
          pledge_sent: true,
          dcaf_soft_pledge: 1000
        }

        pregnancy = patient2.build_pregnancy(creation_hash)
        pregnancy.save
      end
    end

    it 'should return the number of patients who have pregnancies updated within the date range whose pledges are sent' do
      month_num_contacted = Reporting::Patient.pledges_sent_for_line('VA', Time.now - 1.month, Time.now)
      assert_equal 1, month_num_contacted

      year_num_contacted = Reporting::Patient.pledges_sent_for_line('VA', Time.now - 1.year, Time.now)
      assert_equal 2, year_num_contacted
    end
  end
end
