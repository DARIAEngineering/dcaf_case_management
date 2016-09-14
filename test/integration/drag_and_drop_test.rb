require 'test_helper'

class DragAndDropTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in_as @user

    4.times do |i|
      Patient.create name: "Patient #{i}",
                     primary_phone: "123-123-123#{i}",
                     initial_call_date: 3.days.ago,
                     urgent_flag: true,
                     created_by: @user
    end

    Patient.all.each do |patient|

      if patient.name[-1, 1].to_i.even?
        lmp_weeks = (patient.name[-1, 1].to_i + 1) * 2
        lmp_days = 3
      end

      creation_hash = { last_menstrual_period_weeks: lmp_weeks,
                        last_menstrual_period_days: lmp_days,
                        created_by: @user
                      }

      pregnancy = patient.build_pregnancy(creation_hash)
      pregnancy.save

      patient.calls.create! status: 'Left voicemail',
                            created_at: 3.days.ago,
                            created_by: @user
    end

    @user.add_patient Patient.find_by(name: 'Patient 0')
    @user.add_patient Patient.find_by(name: 'Patient 1')
    @user.add_patient Patient.find_by(name: 'Patient 2')
    @user.add_patient Patient.find_by(name: 'Patient 3')
  end

  after do
    Capybara.use_default_driver
    Patient.destroy_all
  end

  describe 'creating and recalling a new patient' do
    it 'should be able to drag and drop bruh' do
      byebug
    end
  end
end
