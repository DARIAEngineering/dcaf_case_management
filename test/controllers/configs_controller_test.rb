require 'test_helper'

class ConfigsControllerTest < ActionDispatch::IntegrationTest
  describe 'non-admin redirects' do
    [:data_volunteer, :cm].each do |role|
      it "should deny access as a #{role}" do
        delete destroy_user_session_path
        user = create :user, role: role
        config = create :config
        sign_in user

        get configs_path
        assert_redirected_to authenticated_root_path

        patch config_path(config, params: { options: ['no'] })
        assert_redirected_to authenticated_root_path
        config.reload
        refute_equal config.options, ['no']
      end
    end
  end

  describe 'authenticated configs' do
    before do
      user = create :user, role: :admin
      @config = create :config
      sign_in user
    end

    it 'should get the index method' do
      get configs_path
      assert_response :success
    end

    it 'should let you update configs' do
      @payload = { options: 'no' }
      patch config_path(@config, params: { config: @payload })
      @config.reload
      assert_equal @config.options, ['no']
    end
  end
end
