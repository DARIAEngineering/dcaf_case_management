require 'test_helper'

class PracticalSupportTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @patient.practical_supports.create created_by: @user,
                                support_type: 'Concert Tickets',
                                source: 'Metallica Abortion Fund'
    @patient.practical_supports.create created_by: @user,
                                support_type: 'Swag',
                                source: 'YOLO AF',
                                confirmed: true
    @psupport1 = @patient.practical_supports.first
    @psupport2 = @patient.practical_supports.last
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @psupport1.respond_to? field
        assert @psupport1[field]
      end
    end

    it 'should respond to history methods' do
      assert @psupport1.respond_to? :history_tracks
      assert @psupport1.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @psupport1.respond_to? :created_by
      assert @psupport1.created_by
    end
  end

  describe 'validations' do
    [:created_by, :source, :support_type].each do |field|
      it "should enforce presence of #{field}" do
        @psupport1[field.to_sym] = nil
        refute @psupport1.valid?
      end
    end

#    it 'should scope support_type uniqueness' do
#      patient = create :patient
#      other_patient = create :patient
#      patients = [patient, other_patient]
#
#      pledge = attributes_for :external_pledge, source: 'Same Fund'
#      other_pledge = attributes_for :external_pledge, source: 'Same Fund', amount: 123
#
#      patients.each { |pt| pt.external_pledges.create pledge }
#      patients.each { |pt| assert_equal 1, pt.external_pledges.count }
#
#      invalid_pledge = patient.external_pledges.create other_pledge
#      patient.reload
#      refute patient.external_pledges.include? invalid_pledge
#      assert_equal 1, patient.external_pledges.count
#    end
  end


end
