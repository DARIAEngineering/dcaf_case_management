require 'test_helper'

class PracticalSupportTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @patient.practical_supports.create support_type: 'Concert Tickets',
                                       source: 'Metallica Abortion Fund'
    @patient.practical_supports.create support_type: 'Swag',
                                       source: 'YOLO AF',
                                       confirmed: true
    @psupport1 = @patient.practical_supports.first
    @psupport2 = @patient.practical_supports.last
  end

  describe 'concerns' do
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
      fields = attributes_for :practical_support, support_type: 'hello'
      support1 = @patient.practical_supports.create fields
      assert support1.valid?

      support2 = @patient.practical_supports.new fields
      refute support2.valid?
      assert_equal ['has already been taken'],
                   support2.errors.messages[:support_type]
    end
  end
end
