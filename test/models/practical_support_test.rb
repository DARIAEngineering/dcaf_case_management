require 'test_helper'

class PracticalSupportTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @patient.practical_supports.create support_type: 'Concert Tickets',
                                       source: 'Metallica Abortion Fund'
    @patient.practical_supports.create support_type: 'Swag',
                                       source: 'YOLO AF',
                                       confirmed: true,
                                       support_date: 2.days.from_now
    @patient.practical_supports.create support_type: 'Companion',
                                       source: 'Cat',
                                       amount: 32
    @psupport1 = @patient.practical_supports.first
    @psupport2 = @patient.practical_supports.second
    @psupport3 = @patient.practical_supports.last
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @psupport1.respond_to? :versions
      assert @psupport1.respond_to? :created_by
      assert @psupport1.respond_to? :created_by_id
    end
  end

  describe 'validations' do
    # note: amount is not required
    [:source, :support_type].each do |field|
      it "should enforce presence of #{field}" do
        @psupport1[field.to_sym] = nil
        refute @psupport1.valid?
      end
    end
  end

  describe 'display_text' do
    it 'should display' do
      assert_equal 'Concert Tickets from Metallica Abortion Fund', @psupport1.display_text
      assert_equal "Swag from YOLO AF (confirmed) on #{2.days.from_now.display_date}", @psupport2.display_text
      assert_equal 'Companion from Cat for $32.00', @psupport3.display_text
    end
  end
end
