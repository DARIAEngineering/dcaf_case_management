require 'test_helper'

class PracticalSupportTest < ActiveSupport::TestCase
  before do
    @patient = create :patient
    @patient.practical_supports.create support_type: 'Concert Tickets',
                                       source: 'Metallica Abortion Fund'
    @patient.practical_supports.create support_type: 'Swag',
                                       source: 'YOLO AF',
                                       confirmed: true
    @psupport1 = @patient.practical_supports.first
    @psupport2 = @patient.practical_supports.last
  end

  describe 'attachments' do
    it 'should respond to history methods' do
      assert @psupport1.respond_to? :versions
      assert @psupport1.respond_to? :created_by
      assert @psupport1.respond_to? :created_by_id
    end
  end

  describe 'validations' do
    [:source, :support_type].each do |field|
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
      assert_equal ['has already been taken'],
                   support2.errors.messages[:support_type]

      pt2 = create :patient
      support3 = pt2.practical_supports.new fields
      assert support3.save
    end
  end
end
