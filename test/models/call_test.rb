require 'test_helper'

class CallTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pregnancy = create :pregnancy
    @call = create :call, pregnancy: @pregnancy, created_by: @user
  end

  it 'SHOULD SOUND THIS ALARM AS LONG AS EVERYTHING IS OKAY' do
    assert @call.valid?
  end

  describe 'basic validations' do
    it 'should only allow certain statuses' do
      [nil, 'not a status'].each do |bad_status|
        @call.status = bad_status
        refute @call.valid?
      end
      ['Left voicemail', "Couldn't reach patient"].each do |status|
        @call.status = status
        assert @call.valid?
      end
    end

    it 'should require a user id' do
      @call.created_by = nil
      refute @call.valid?
    end
  end

  describe 'relationships' do
    it 'should be linkable to a pregnancy' do
      assert_equal @call.pregnancy, @pregnancy
    end

    it 'should be linkable to a user' do
      assert_equal @call.created_by, @user
    end
  end
end
