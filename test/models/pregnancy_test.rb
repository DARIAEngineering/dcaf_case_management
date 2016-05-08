require 'test_helper'

class PregnancyTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pt_1 = create :patient, name: 'Susan Everywoman', primary_phone: '123-456-6789'
    @pt_2 = create :patient, name: 'Susan Everyteen', primary_phone: '123-456-6789'
    @pt_3 = create :patient, name: 'Susan Everygirl', secondary_phone: '999-999-9999'
    [@pt_1, @pt_2, @pt_3].each do |pt|
      create :pregnancy, patient: pt, created_by: @user
    end
    @pregnancy = @pt_1.pregnancies.first
  end

  describe 'validations' do
    %w(initial_call_date created_by).each do |field|
      it "should enforce presence of #{field}" do
        @pregnancy[field.to_sym] = nil
        refute @pregnancy.valid?
      end
    end
  end

  describe 'search method' do
    it 'should respond to search' do
      assert Patient.respond_to? :search
    end

    it 'should find a patient' do
      assert_equal Patient.search('Susan Everywoman').count, 1
    end

    it 'should find multiple patients if there are multiple' do
      assert_equal Patient.search('123-456-6789').count, 2
    end

    it 'should be able to find based on secondary phones too' do
      assert_equal Patient.search('999-999-9999').count, 1
    end
  end

  describe 'status method' do
    it 'should default to "No Contact Made" when a pregnancy has no calls' do
      assert_equal 'No Contact Made', @pregnancy.status
    end

    it 'should default to "No Contact Made" when a pregnancy has an unsuccessful call' do
      create :call, pregnancy: @pregnancy, status: 'Left voicemail'
      assert_equal 'No Contact Made', @pregnancy.status
    end

    it 'should update to "Needs Appointment" once patient has been reached' do
      create :call, pregnancy: @pregnancy, status: 'Reached patient'
      assert_equal 'Needs Appointment', @pregnancy.status
    end

    it 'should update to "Fundraising" once an appointment has been made' do
      @pregnancy.appointment_date = '01/01/2017'
      assert_equal 'Fundraising', @pregnancy.status
    end

    # it 'should update to "Sent Pledge" after a pledge has been sent' do
    # end

    # it 'should update to "Pledge Paid" after a pledge has been paid' do
    # end

    # it 'should update to "Resolved Without DCAF" if a pregnancy is marked resolved' do
    # end
  end

  describe 'contact_made? method' do
    it 'should return false if no calls have been made' do
      refute @pregnancy.send :contact_made?
    end

    it 'should return false if an unsuccessful call has been made' do
      create :call, pregnancy: @pregnancy, status: 'Left voicemail'
      refute @pregnancy.send :contact_made?
    end

    it 'should return true if a successful call has been made' do
      create :call, pregnancy: @pregnancy, status: 'Reached patient'
      assert @pregnancy.send :contact_made?
    end
  end

  describe 'last menstrual period helper methods' do
    before do
      @patient = create :patient, created_by: @user
      @pregnancy = create :pregnancy, last_menstrual_period_weeks: 9, last_menstrual_period_days: 2, initial_call_date: 2.days.ago, created_by: @user
    end

    it 'LMP on date - should nil out if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today)
    end

    it 'LMP on date - should accurately calculate LMP on a given date' do
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 67
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, 5.days.from_now.to_date), 72

      @pregnancy.initial_call_date = 4.days.ago
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 69

      @pregnancy.last_menstrual_period_weeks = 10
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 76

      @pregnancy.last_menstrual_period_days = 6
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 80
    end

    it 'LMP now - should return nil if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.send(:last_menstrual_period_now)
    end

    it 'LMP now - should be equivalent to LMP on date - Time.zone.today' do
      assert_equal @pregnancy.send(:last_menstrual_period_now), @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today)
    end

    it 'LMP display - should return nil if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.last_menstrual_period_display
    end

    it 'LMP display - should return LMP in weeks and days' do
      assert_equal @pregnancy.last_menstrual_period_display, '9 weeks, 4 days'
    end

    it 'LMP display short - should return nil if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.last_menstrual_period_display_short
    end

    it 'LMP display short - should return shorter LMP in weeks and days' do
      assert_equal @pregnancy.last_menstrual_period_display_short, '9w 4d'
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
end
