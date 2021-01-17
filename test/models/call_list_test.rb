require 'test_helper'

class CallListTest < ActiveSupport::TestCase
  before do
    @call_list_entry = create :call_list
  end

  describe 'validations' do
    it 'should be able to build an object' do
      assert @call_list_entry.valid?
    end

    %i(order_key line).each do |field|
      it "should enforce presence of #{field}" do
        @call_list_entry[field] = nil
        refute @call_list_entry.valid?
      end
    end

    it 'should have a unique patient_id by user' do
      call_list_pt = @call_list_entry.patient_id
      call_list_user = @call_list_entry.user_id

      bad_entry = build :call_list, patient_id: call_list_pt, user_id: call_list_user
      refute bad_entry.valid?
      assert_equal 'Patient is already taken',
                   bad_entry.errors.full_messages.first
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @call_list_entry.respond_to? field
        assert @call_list_entry[field]
      end
    end
  end
end
