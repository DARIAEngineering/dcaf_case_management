# in test/helpers/omniauth_helper.rb
RSpec.configure do |config|
    OmniAuth.config.mock_auth[:google_oauth2] = {
      'provider' => 'google_oauth2',
      'uid' => '111696567596812172783',
      'info' => {
        'email' => 'dcaf.testing@gmail.com',
        'first_name' => 'DCAF',
        'last_name' => 'Testing',
        'image' => 'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg'
      },
      'credentials' => {
        'token' => 'ya29.Ci_LA4hiS1Zh2Pj9PuU9aaa6QuB4yH8VEuPgCR642H9E5ZDfFr_amKNlr48GUPfC_Q',
        'expires_at' => DateTime.now
      }
    }
end

OmniAuth.config.test_mode = true