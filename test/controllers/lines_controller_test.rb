require 'test_helper'

# Test lines setting behavior
class LinesControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @line = create :line
    sign_in @user
  end

  describe 'new' do
    describe 'instance with multiple lines' do
      # Stub a second line
      before { create :line }

      it 'should return success' do
        get new_line_path
        assert_response :success
      end
    end

    describe 'instance with one line' do
      it 'should redirect to patient dashboard' do
        get new_line_path
        assert_redirected_to authenticated_root_path
        assert_equal @line.id, session[:line_id]
        assert_equal @line.name, session[:line_name]
      end
    end
  end

  describe 'create' do
    before do
      post lines_path, params: { line_id: @line.id }
    end

    it 'should set a session variable' do
      assert_equal @line.id, session[:line_id]
      assert_equal @line.name, session[:line_name]
    end

    # TODO: Enforce line values
    # it 'should reject anything not set in lines' do
    # end
  end
end
