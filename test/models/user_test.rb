require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Since this is a devise install, devise is handling
  # general stuff like creation timestamps etc.
  before do
    @user = create :user
  end

  describe 'basic validations' do
    it 'should be able to build an object' do
      assert @user.valid?
    end

    %w(email name).each do |attribute|
      it "should require content in #{attribute}" do
        @user[attribute.to_sym] = nil
        assert_not @user.valid?
        assert_equal "can't be blank",
                     @user.errors.messages[attribute.to_sym].first
      end
    end
  end

  describe 'call list methods' do
    before do
      @pregnancy = create :pregnancy
      @pregnancy_2 = create :pregnancy
      @user.pregnancies << @pregnancy
      @user.pregnancies << @pregnancy_2
      @user_2 = create :user
    end

    it 'should return recently_called_pregnancies accurately' do
      assert_equal 0, @user.recently_called_pregnancies.count
      @call = create :call, pregnancy: @pregnancy, created_by: @user
      assert_equal 1, @user.recently_called_pregnancies.count
    end

    it 'should return call_list_pregnancies accurately' do
      assert_equal 2, @user.call_list_pregnancies.count
      @call = create :call, pregnancy: @pregnancy, created_by: @user
      assert_equal 1, @user.call_list_pregnancies.count
      @call_2 = create :call, pregnancy: @pregnancy_2, created_by: @user_2
      assert_equal 1, @user.call_list_pregnancies.count
    end

    it 'should accurately flag a pregnancy as recently called or not' do
      refute @user.recently_called? @pregnancy
      @call = create :call, pregnancy: @pregnancy, created_by: @user
      assert @user.recently_called? @pregnancy
    end
  end

  describe 'pregnancy methods' do
    before do
      @pregnancy = create :pregnancy
      @pregnancy_2 = create :pregnancy
      @pregnancy_3 = create :pregnancy
    end

    it 'add pregnancy - should add a pregnancy to a set' do
      assert_difference '@user.pregnancies.count', 1 do
        @user.add_pregnancy @pregnancy
      end
    end

    it 'remove pregnancy - should remove a pregnancy from a set' do
      @user.add_pregnancy @pregnancy
      assert_difference '@user.pregnancies.count', -1 do
        @user.remove_pregnancy @pregnancy
      end
    end

    describe 'reorder call list' do
      before do
        set_of_pregnancies = [@pregnancy, @pregnancy_2, @pregnancy_3]
        set_of_pregnancies.each { |preg| @user.add_pregnancy preg }
        @new_order = [@pregnancy_3._id.to_s, @pregnancy._id.to_s, @pregnancy_2._id.to_s]
        @user.reorder_call_list @new_order
      end

      it 'should let you reorder a call list' do
        assert_equal @pregnancy_3, @user.ordered_pregnancies.first
        assert_equal @pregnancy, @user.ordered_pregnancies[1]
        assert_equal @pregnancy_2, @user.ordered_pregnancies[2]
      end

      it 'should not choke if another preg is on call list but not call order' do
        @pregnancy_4 = create :pregnancy
        @user.add_pregnancy @pregnancy_4

        assert @user.ordered_pregnancies.include? @pregnancy_4
        refute @user.call_order.include? @pregnancy_4._id.to_s
      end
    end
  end

  describe 'relationships' do
    before do
      @pregnancy = create :pregnancy
      @pregnancy_2 = create :pregnancy
      @user.pregnancies << @pregnancy
      @user.pregnancies << @pregnancy_2
      @user_2 = create :user
    end

    it 'should have any belong to many pregnancies' do
      [@pregnancy, @pregnancy_2].each do |preg|
        [@user, @user_2].each { |user| user.add_pregnancy preg }
      end

      assert_equal @user.pregnancies, @user_2.pregnancies
    end
  end
end
