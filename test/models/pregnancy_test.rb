require 'test_helper'

class PregnancyTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pt_1 = create :patient, name: 'Susan Smith'
    @pt_2 = create :patient, name: 'Susan E'
    @pt_3 = create :patient, name: 'Susan All', other_phone: '999-999-9999'
    [@pt_1, @pt_2, @pt_3].each do |pt|
      create :pregnancy, patient: pt, created_by: @user
    end
    @pregnancy = @pt_1.pregnancy
  end

  describe 'validations' do
    it 'should be able to build an object' do
      assert @pregnancy.valid?
    end

    %w(created_by).each do |field|
      it "should enforce presence of #{field}" do
        @pregnancy[field.to_sym] = nil
        refute @pregnancy.valid?
      end
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @pregnancy.respond_to? field
        assert @pregnancy[field]
      end
    end

    it 'should respond to history methods' do
      assert @pregnancy.respond_to? :history_tracks
      assert @pregnancy.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @pregnancy.respond_to? :created_by
      assert @pregnancy.created_by
    end
  end

  before do
    @pregnancy.dcaf_soft_pledge = 500
    @pt_1.clinic_name = 'Nice Clinic'
    @pt_1.appointment_date = DateTime.now + 14
  end

  describe 'pledge_sent validation' do
    it 'should validate pledge_sent when all items in #check_other_validations? are present' do
      @pregnancy.pledge_sent = true
      assert @pregnancy.valid?
    end

    it 'should not validate pledge_sent if the DCAF soft pledge field is blank' do
      @pregnancy.dcaf_soft_pledge = nil
      @pregnancy.pledge_sent = true
      refute @pregnancy.valid?
      assert_equal ['DCAF soft pledge field cannot be blank'], @pregnancy.errors.messages[:pledge_sent]
    end

    it 'should not validate pledge_sent if the clinic name is blank' do
      @pt_1.clinic_name = nil
      @pregnancy.pledge_sent = true
      refute @pregnancy.valid?
      assert_equal ['Clinic name cannot be blank'], @pregnancy.errors.messages[:pledge_sent]
    end

    it 'should not validate pledge_sent if the appointment date is blank' do
      @pt_1.appointment_date = nil
      @pregnancy.pledge_sent = true
      refute @pregnancy.valid?
      assert_equal ['Appointment date cannot be blank'], @pregnancy.errors.messages[:pledge_sent]
    end

    it 'should produce three error messages if three required fields are blank' do
      @pregnancy.dcaf_soft_pledge = nil
      @pt_1.clinic_name = nil
      @pt_1.appointment_date = nil
      @pregnancy.pledge_sent = true
      refute @pregnancy.valid?
      assert_equal ['DCAF soft pledge field cannot be blank', 'Clinic name cannot be blank', 'Appointment date cannot be blank'],
      @pregnancy.errors.messages[:pledge_sent]
    end

    it 'should have convenience methods to render in view, just in case' do
      refute @pregnancy.pledge_info_present?
      @pregnancy.dcaf_soft_pledge = nil
      assert @pregnancy.pledge_info_present?
      assert_equal ['DCAF soft pledge field cannot be blank'], @pregnancy.pledge_info_errors
    end
  end
end
