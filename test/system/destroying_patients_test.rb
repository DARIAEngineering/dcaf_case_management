require 'application_system_test_case'

class DestroyingPatientsTest < ApplicationSystemTestCase
  describe 'destroying a patient' do
    before do
      @user = create :user, role: :cm
      @admin = create :user, role: :admin
      @data_volunteer = create :user, role: :data_volunteer
      @patient = create :patient
      @pledged_patient = create :patient, appointment_date: 2.days.from_now,
                                          clinic: (create :clinic),
                                          fund_pledge: 100
    end


    describe 'hide the button for nonadmins' do
      it "should not show the destroy button to CMs" do
        log_in_as @user
        visit edit_patient_path @patient
        refute has_button? 'Delete duplicate'
      end

      it "should not show the destroy button to data vols" do
        log_in_as @data_volunteer
        visit edit_patient_path @patient
        refute has_button? 'Delete duplicate'
      end
    end

    describe 'administratively deleting a duplicate patient' do
      before { log_in_as @admin }

      it 'should remove that patient from the db' do
        visit edit_patient_path @patient

        assert_difference 'Patient.count', -1 do
          accept_confirm { click_button 'Delete duplicate patient record' }
        end
        assert_equal root_path, current_path
        assert has_content? 'removed from database'

        visit edit_patient_path(@patient)
        assert_redirected_to root_path
      end

      it 'should not let you delete patients with pledges' do
        visit edit_patient_path @pledged_patient

        assert_no_difference 'Patient.count' do
          accept_confirm { click_button 'Delete duplicate patient record' }
        end
        assert_equal edit_patient_path(@patient), current_path
        assert has_content? 'please correct the patient record'
      end
    end
  end
end
