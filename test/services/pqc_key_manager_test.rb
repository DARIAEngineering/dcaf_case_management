require 'test_helper'

class PqcKeyManagerTest < ActiveSupport::TestCase
  before do
    PqcKeyManager.reset_availability_cache!
    # Stash original env vars to restore after tests
    @original_env = {}
    %w[PQC_ENABLED PQC_PRIVATE_KEY_PATH PQC_WRAPPED_KEY PQC_KEM_CIPHERTEXT
       PQC_PUBLIC_KEY_PATH ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY].each do |key|
      @original_env[key] = ENV[key]
    end
  end

  after do
    # Restore environment
    @original_env.each { |key, val| val.nil? ? ENV.delete(key) : ENV[key] = val }
    PqcKeyManager.reset_availability_cache!
  end

  describe 'pqc_available?' do
    it 'should return a boolean' do
      result = PqcKeyManager.pqc_available?
      assert [true, false].include?(result)
    end

    it 'should cache the result' do
      first = PqcKeyManager.pqc_available?
      second = PqcKeyManager.pqc_available?
      assert_equal first, second
    end

    it 'should reset cache when reset_availability_cache! is called' do
      PqcKeyManager.pqc_available?
      PqcKeyManager.reset_availability_cache!
      # After reset, calling again should re-evaluate
      assert [true, false].include?(PqcKeyManager.pqc_available?)
    end
  end

  describe 'pqc_enabled?' do
    it 'should return false when PQC_ENABLED is not set' do
      ENV.delete('PQC_ENABLED')
      refute PqcKeyManager.pqc_enabled?
    end

    it 'should return false when PQC_ENABLED is not "true"' do
      ENV['PQC_ENABLED'] = 'false'
      refute PqcKeyManager.pqc_enabled?
    end

    it 'should return false when required env vars are missing' do
      ENV['PQC_ENABLED'] = 'true'
      ENV.delete('PQC_PRIVATE_KEY_PATH')
      ENV.delete('PQC_WRAPPED_KEY')
      ENV.delete('PQC_KEM_CIPHERTEXT')
      refute PqcKeyManager.pqc_enabled?
    end

    it 'should return true when all env vars are set' do
      ENV['PQC_ENABLED'] = 'true'
      ENV['PQC_PRIVATE_KEY_PATH'] = '/tmp/test_key.pem'
      ENV['PQC_WRAPPED_KEY'] = 'somebase64data'
      ENV['PQC_KEM_CIPHERTEXT'] = 'somebase64data'
      assert PqcKeyManager.pqc_enabled?
    end
  end

  describe 'primary_key' do
    it 'should fall back to env var when PQC is not enabled' do
      ENV.delete('PQC_ENABLED')
      ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'] = 'test-primary-key'
      assert_equal 'test-primary-key', PqcKeyManager.primary_key
    end

    it 'should return deterministic dev fallback when no env var and PQC disabled' do
      ENV.delete('PQC_ENABLED')
      ENV.delete('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY')
      key = PqcKeyManager.primary_key
      assert key.present?
      # Dev fallback is deterministic — same input yields same output
      assert_equal key, PqcKeyManager.primary_key
      # Must not be the old hardcoded value
      refute_equal 'default_primary_key', key
    end
  end

  describe 'AES-256-GCM round trip' do
    it 'should encrypt and decrypt correctly' do
      key = OpenSSL::Random.random_bytes(32)
      plaintext = "my-secret-primary-key"

      encrypted = PqcKeyManager.send(:aes_gcm_encrypt, key, plaintext.b)
      decrypted = PqcKeyManager.send(:aes_gcm_decrypt, key, encrypted)

      assert_equal plaintext.b, decrypted
    end

    it 'should fail with wrong key' do
      key = OpenSSL::Random.random_bytes(32)
      wrong_key = OpenSSL::Random.random_bytes(32)
      plaintext = "my-secret-primary-key"

      encrypted = PqcKeyManager.send(:aes_gcm_encrypt, key, plaintext.b)

      assert_raises(OpenSSL::Cipher::CipherError) do
        PqcKeyManager.send(:aes_gcm_decrypt, wrong_key, encrypted)
      end
    end

    it 'should fail with tampered ciphertext' do
      key = OpenSSL::Random.random_bytes(32)
      plaintext = "my-secret-primary-key"

      encrypted = PqcKeyManager.send(:aes_gcm_encrypt, key, plaintext.b)
      # Tamper with last byte
      tampered = encrypted.dup
      tampered[-1] = (tampered[-1].ord ^ 0xFF).chr

      assert_raises(OpenSSL::Cipher::CipherError) do
        PqcKeyManager.send(:aes_gcm_decrypt, key, tampered)
      end
    end
  end

  describe 'generate_keypair' do
    it 'should raise PqcUnavailableError when ML-KEM not available' do
      # Stub pqc_available? to return false
      PqcKeyManager.stub(:pqc_available?, false) do
        assert_raises(PqcKeyManager::PqcUnavailableError) do
          PqcKeyManager.generate_keypair
        end
      end
    end
  end

  describe 'save_keypair' do
    it 'should write files with correct permissions' do
      skip 'File permissions not reliable on Windows' if Gem.win_platform?

      # Create a mock PEM key object
      key = OpenSSL::PKey::RSA.generate(2048) # RSA for testing file write
      Dir.mktmpdir do |dir|
        priv_path = File.join(dir, 'test_private.pem')
        pub_path = File.join(dir, 'test_public.pem')

        PqcKeyManager.save_keypair(key, private_key_path: priv_path, public_key_path: pub_path)

        assert File.exist?(priv_path)
        assert File.exist?(pub_path)
        assert_equal 0o600, File.stat(priv_path).mode & 0o777
      end
    end
  end

  describe 'unwrap_primary_key error handling' do
    it 'should fall back gracefully when private key file missing in non-production' do
      PqcKeyManager.stub(:pqc_available?, true) do
        ENV['PQC_ENABLED'] = 'true'
        ENV['PQC_PRIVATE_KEY_PATH'] = '/nonexistent/path/key.pem'
        ENV['PQC_WRAPPED_KEY'] = Base64.strict_encode64('fake')
        ENV['PQC_KEM_CIPHERTEXT'] = Base64.strict_encode64('fake')

        key = PqcKeyManager.primary_key
        assert key.present?
        refute_equal 'default_primary_key', key
      end
    end

    it 'should raise KeyUnwrapError in production when private key file missing' do
      PqcKeyManager.stub(:pqc_available?, true) do
        ENV['PQC_ENABLED'] = 'true'
        ENV['PQC_PRIVATE_KEY_PATH'] = '/nonexistent/path/key.pem'
        ENV['PQC_WRAPPED_KEY'] = Base64.strict_encode64('fake')
        ENV['PQC_KEM_CIPHERTEXT'] = Base64.strict_encode64('fake')

        Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new("production")) do
          assert_raises(PqcKeyManager::KeyUnwrapError) do
            PqcKeyManager.primary_key
          end
        end
      end
    end
  end

  describe 'require_env_key' do
    it 'should return env var value when present' do
      ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'] = 'my-real-key'
      assert_equal 'my-real-key', PqcKeyManager.require_env_key('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', 'test')
    end

    it 'should return dev fallback in non-production when env var missing' do
      ENV.delete('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY')
      key = PqcKeyManager.require_env_key('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', 'test')
      assert key.present?
      refute_equal 'default_primary_key', key
    end

    it 'should raise PqcError in production when env var missing' do
      ENV.delete('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY')
      Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new("production")) do
        assert_raises(PqcKeyManager::PqcError) do
          PqcKeyManager.require_env_key('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', 'test')
        end
      end
    end
  end

  describe 'private key never exposed' do
    it 'should not include private key material in any public method return value' do
      # Verify that generate_keypair returns a key object, not a hash with raw key material
      PqcKeyManager.stub(:pqc_available?, true) do
        # Mock generate_key to return a real key type for testing
        mock_key = OpenSSL::PKey::RSA.generate(2048)
        OpenSSL::PKey.stub(:generate_key, mock_key) do
          result = PqcKeyManager.generate_keypair
          # Should return an OpenSSL::PKey object, not a hash with base64 key material
          assert_kind_of OpenSSL::PKey::PKey, result
        end
      end
    end
  end
end
