require 'test_helper'

class ExternalPledgeTest < ActiveSupport::TestCase
  before do
    @patient = create :patient
    @patient.external_pledges.create amount: 100,
                                     source: 'BWAH'
    @pledge = @patient.external_pledges.first
  end

  describe 'attachments' do
    it 'should respond to history methods' do
      assert @pledge.respond_to? :versions
      assert @pledge.respond_to? :created_by
      assert @pledge.respond_to? :created_by_id
    end
  end

  describe 'validations' do
    [:source].each do |field|
      it "should enforce presence of #{field}" do
        @pledge[field.to_sym] = nil
        refute @pledge.valid?
      end
    end

    it 'should scope source uniqueness to a particular patient' do
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
      @patient.external_pledges.create! amount: 100,
                                        source: 'Bar',
                                        active: false
    end

    it 'should leave inactive pledges out unless specified queries' do
      @patient.reload
      assert_equal 1, @patient.external_pledges.count
      assert_equal 1, @patient.external_pledges.active.count
      assert_equal 2, @patient.external_pledges.unscoped.count
    end
  end
end
