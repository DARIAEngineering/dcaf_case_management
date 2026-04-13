require 'test_helper'

class NoteTemplateTest < ActiveSupport::TestCase
  before do
    @user = create :user
  end

  describe 'validations' do
    it 'should be valid with name and full_text' do
      template = build :note_template, user: @user
      assert template.valid?
    end

    it 'should require name' do
      template = build :note_template, user: @user, name: nil
      refute template.valid?
      assert template.errors[:name].any?
    end

    it 'should require full_text' do
      template = build :note_template, user: @user, full_text: nil
      refute template.valid?
      assert template.errors[:full_text].any?
    end

    it 'should enforce uniqueness scoped to fund_id and user_id' do
      create :note_template, user: @user, name: 'Duplicate'
      duplicate = build :note_template, user: @user, name: 'Duplicate'
      refute duplicate.valid?
    end

    it 'should allow same name for different users' do
      other_user = create :user
      create :note_template, user: @user, name: 'Shared Name'
      other = build :note_template, user: other_user, name: 'Shared Name'
      assert other.valid?
    end
  end

  describe 'scopes' do
    it 'should return fund-level templates with fund_level scope' do
      fund_template = create :note_template, user: nil, name: 'Fund Template'
      personal = create :note_template, user: @user, name: 'Personal'

      results = NoteTemplate.fund_level
      assert_includes results, fund_template
      refute_includes results, personal
    end

    it 'should return only user templates with personal scope' do
      personal = create :note_template, user: @user, name: 'My Template'
      other_user = create :user
      other = create :note_template, user: other_user, name: 'Other Template'

      results = NoteTemplate.personal(@user)
      assert_includes results, personal
      refute_includes results, other
    end

    it 'should return fund-level + personal with available_to scope' do
      fund_template = create :note_template, user: nil, name: 'Fund Wide'
      personal = create :note_template, user: @user, name: 'My Own'
      other_user = create :user
      other = create :note_template, user: other_user, name: 'Someone Else'

      results = NoteTemplate.available_to(@user)
      assert_includes results, fund_template
      assert_includes results, personal
      refute_includes results, other
    end

    it 'should order available_to results by name' do
      create :note_template, user: @user, name: 'Zebra template'
      create :note_template, user: @user, name: 'Alpha template'

      results = NoteTemplate.available_to(@user)
      assert_equal results.first.name, 'Alpha template'
    end
  end

  describe 'dependent destroy' do
    it 'should destroy templates when user is destroyed' do
      template = create :note_template, user: @user, name: 'Will Be Deleted'
      assert_difference 'NoteTemplate.count', -1 do
        @user.destroy
      end
    end
  end
end
