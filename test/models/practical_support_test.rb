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

    it 'should enforce uniqueness of support_type' do
      fields = attributes_for :practical_support
      support1 = @patient.practical_supports.new fields
      assert support1.save

      support2 = @patient.practical_supports.new fields
      refute support2.save
      assert_equal ['is already taken'],
                   support2.errors.messages[:support_type]
    end
  end
end
