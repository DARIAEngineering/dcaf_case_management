require 'test_helper'

class CallListEntryTest < ActiveSupport::TestCase
  before do
    @call_list_entry = create :call_list_entry
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

      entry = build :call_list_entry, patient_id: call_list_pt,
                                      user_id: call_list_user
      refute entry.valid?
      assert_equal 'Patient has already been taken',
                   entry.errors.full_messages.first

      entry.user = create :user
      assert entry.valid?
    end
  end
end
