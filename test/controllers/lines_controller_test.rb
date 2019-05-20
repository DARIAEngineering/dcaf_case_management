require 'test_helper'

# Test lines setting behavior
class LinesControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'
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
        Object.stub_const(:LINES, ['DC']) do
          get new_line_path
          assert_equal 'DC', session[:line]
          assert_redirected_to authenticated_root_path
        end
      end
    end
  end

  describe 'create' do
    before do
      post lines_path, params: { line: 'MD' }
    end

    it 'should set a session variable' do
      assert_equal 'MD', session[:line]
    end

    # TODO: Enforce line values
    # it 'should reject anything not set in lines' do
    # end
  end
end
