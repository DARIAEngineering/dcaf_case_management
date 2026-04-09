require 'test_helper'

class NoteTemplatesControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @admin = create :user, role: :admin
    @line = create :line
    sign_in @user
    choose_line @line
  end

  describe 'index' do
    it 'should return templates as JSON for current user' do
      fund_template = create :note_template, user: nil, name: 'Fund Template'
      personal = create :note_template, user: @user, name: 'My Template'

      get note_templates_path(format: :json)
      assert_response :success

      json = JSON.parse(response.body)
      names = json.map { |t| t['name'] }
      assert_includes names, 'Fund Template'
      assert_includes names, 'My Template'
    end

    it 'should not return other users templates' do
      other_user = create :user
      other = create :note_template, user: other_user, name: 'Private Template'

      get note_templates_path(format: :json)
      json = JSON.parse(response.body)
      names = json.map { |t| t['name'] }
      refute_includes names, 'Private Template'
    end
  end

  describe 'create' do
    it 'should create a personal template' do
      assert_difference 'NoteTemplate.count', 1 do
        post note_templates_path, params: {
          note_template: { name: 'New Template', full_text: 'Template body text' }
        }
      end

      template = NoteTemplate.last
      assert_equal @user.id, template.user_id
      assert_equal 'New Template', template.name
      assert_redirected_to authenticated_root_path
    end

    it 'should reject template without name' do
      assert_no_difference 'NoteTemplate.count' do
        post note_templates_path, params: {
          note_template: { name: '', full_text: 'Body' }
        }
      end
    end
  end

  describe 'destroy' do
    it 'should allow user to delete own template' do
      template = create :note_template, user: @user, name: 'Delete Me'

      assert_difference 'NoteTemplate.count', -1 do
        delete note_template_path(template)
      end
    end

    it 'should not allow user to delete other users template' do
      other = create :user
      template = create :note_template, user: other, name: 'Not Mine'

      assert_no_difference 'NoteTemplate.count' do
        delete note_template_path(template)
      end
      assert_match(/not authorized/i, flash[:alert])
    end

    it 'should not allow non-admin to delete fund-level template' do
      fund_template = create :note_template, user: nil, name: 'Fund Level'

      assert_no_difference 'NoteTemplate.count' do
        delete note_template_path(fund_template)
      end
      assert_match(/not authorized/i, flash[:alert])
    end

    it 'should allow admin to delete fund-level template' do
      sign_in @admin
      choose_line @line
      fund_template = create :note_template, user: nil, name: 'Fund Level Admin'

      assert_difference 'NoteTemplate.count', -1 do
        delete note_template_path(fund_template)
      end
    end
  end
end
