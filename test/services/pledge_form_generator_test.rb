require 'test_helper'

class PledgeFormGeneratorTest < ActiveSupport::TestCase
  before do
    @user = create :user, name: 'Da User'
    pregnancy = create :pregnancy, dcaf_soft_pledge: 300, naf_pledge: 200
    @patient = create :patient, name: 'Sarah', other_phone: '111-222-3333', pregnancy: pregnancy,
                      other_contact: 'Yolo', initial_call_date: Date.new(2015, 12, 1), appointment_date: Date.new(2016, 1, 1), clinic_name: 'Da Clinic'
    @case_manager_name = 'Angela Davis'
  end

  describe 'user data' do
    before do
      @pledge_form_generator = PledgeFormGenerator.new(@user, @patient, @case_manager_name)
      @pdf_text = PDF::Inspector::Text.analyze(@pledge_form_generator.generate_pledge_pdf.render).strings
    end

    describe 'variable text' do
      it 'should include dynamically generated information' do
        assert_includes(@pdf_text, 'Angela Davis')
        assert_includes(@pdf_text, 'will be remitted to the abortion provider, Da Clinic located in Washington, District of Colombia.')
      end
    end

    it 'should get the clinic date formatted' do
      assert_equal(@pledge_form_generator.appointment_date, 'January 1, 2016')
    end

    it 'should get the patient provider name' do
      assert_equal(@pledge_form_generator.patient_provider_name, 'Da Clinic')
    end

    it 'should get the amount pledged' do
      assert_equal(@pledge_form_generator.patient_amount, 300)
    end

    it 'should get the patient name' do
      assert_equal(@pledge_form_generator.patient_name, 'Sarah')
    end

    it 'should get the current user name' do
      assert_equal(@pledge_form_generator.case_manager_name, 'Angela Davis')
    end
  end
end
