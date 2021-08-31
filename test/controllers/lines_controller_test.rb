require 'test_helper'

# Test lines setting behavior
class LinesControllerTest < ActionDispatch::IntegrationTest
  before do
    @lines = [
      create(:line, name: 'DC'),
      create(:line, name: 'MD'),
      create(:line, name: 'VA'),
    ]
    @user = create :user
    sign_in @user
  end

  describe 'new' do
    describe 'instance with multiple lines' do
      it 'should return success' do
        get new_line_path
        assert_response :success
      end
    end

    describe 'instance with one line' do
      it 'should redirect to patient dashboard' do
        Line.destroy_all
        line = create :line, name: 'DC'
        get new_line_path
        assert_equal 'DC', session[:line_name]
        assert_equal line.id, session[:line_id]
        assert_redirected_to authenticated_root_path
      end
    end
  end

  describe 'create' do
    before do
      post lines_path, params: { id: @lines[1].id }
    end

    it 'should set a session variable' do
      assert_equal 'MD', session[:line_name]
      assert_equal @lines[1].id, session[:line_id]
    end

    # TODO: Enforce line values
    # it 'should reject anything not set in lines' do
    # end
  end
end
