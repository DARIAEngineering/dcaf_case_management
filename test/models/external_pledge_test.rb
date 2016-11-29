require 'test_helper'

class ExternalPledgeTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @pledge = create :external_pledge, patient: @patient, created_by: @user
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @pledge.respond_to? field
        assert @pledge[field]
      end
    end

    it 'should respond to history methods' do
      assert @pledge.respond_to? :history_tracks
      assert @pledge.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @pledge.respond_to? :created_by
      assert @pledge.created_by
    end
  end

  describe 'validations' do
    [:created_by, :source].each do |field|
      it "should enforce presence of #{field}" do
        @pledge[field.to_sym] = nil
        refute @pledge.valid?
      end
    end

    it 'should scope source uniqueness to a particular document' do
      patient = create :patient
      other_patient = create :patient
      patients = [patient, other_patient]

      pledge = attributes_for :external_pledge, source: 'Same Fund'
      other_pledge = attributes_for :external_pledge, source: 'Same Fund', amount: 123

      patients.each { |pt| pt.external_pledges.create pledge }
      patients.each { |pt| assert_equal 1, pt.external_pledges.count }

      invalid_pledge = patient.external_pledges.create other_pledge
      patient.reload
      refute patient.external_pledges.include? invalid_pledge
      assert_equal 1, patient.external_pledges.count
    end
  end

  describe 'scopes' do
    before do
      @inactive_pledge = create :external_pledge,
                                source: 'something or other',
                                active: false,
                                patient: @patient
    end

    it 'should leave inactive pledges out unless specified queries' do
      @patient.reload
      assert_equal 1, @patient.external_pledges.count
      assert_equal 1, @patient.external_pledges.active.count
      assert_equal 2, @patient.external_pledges.unscoped.count
    end
  end
end
