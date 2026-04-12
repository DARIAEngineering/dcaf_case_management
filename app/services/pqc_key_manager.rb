# Post-Quantum Cryptography hybrid key manager.
#
# Wraps Rails Active Record encryption keys using ML-KEM-1024 (FIPS 203)
# combined with AES-256-GCM for quantum-resistant key protection.
#
# Hybrid approach: Even if ML-KEM is broken, the AES layer still protects
# the key. Even if AES is broken, ML-KEM still protects the key.
#
# Requires OpenSSL 3.5+ with ML-KEM support (provided by upgrade/openssl-3.5.5).
#
# Environment variables:
#   PQC_ENABLED          - Set to "true" to enable PQC key unwrapping
#   PQC_PRIVATE_KEY_PATH - Path to ML-KEM-1024 private key PEM file
#   PQC_WRAPPED_KEY      - Base64-encoded AES-256-GCM encrypted primary key
#   PQC_KEM_CIPHERTEXT   - Base64-encoded ML-KEM ciphertext (encapsulated shared secret)
#
# Dual-read: If PQC env vars are set, unwraps the key. Otherwise falls back
# to the raw ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY env var.
class PqcKeyManager
  PQC_ALGORITHM = "ML-KEM-1024".freeze

  class PqcError < StandardError; end
  class KeyUnwrapError < PqcError; end
  class PqcUnavailableError < PqcError; end

  # Check if ML-KEM-1024 is available in the current OpenSSL installation
  def self.pqc_available?
    return @pqc_available unless @pqc_available.nil?

    @pqc_available = begin
      key = OpenSSL::PKey.generate_key(PQC_ALGORITHM)
      key.respond_to?(:encapsulate) && key.respond_to?(:decapsulate)
    rescue => _e
      false
    end
  end

  # Reset cached availability (for testing)
  def self.reset_availability_cache!
    @pqc_available = nil
  end

  # Returns the primary encryption key, unwrapping via PQC if configured.
  # Production: raises if keys are missing. Dev/test: generates fallback.
  def self.primary_key
    if pqc_enabled?
      unwrap_primary_key
    else
      require_env_key("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "primary encryption key")
    end
  rescue PqcError => e
    raise if Rails.env.production?
    warn "[PQC] #{e.message} — using development fallback. DO NOT use in production."
    dev_fallback_key("primary")
  end

  # Load a required encryption key from ENV with environment-aware guard.
  # Production: raises if missing. Dev/test: generates deterministic fallback.
  def self.require_env_key(env_var, description)
    value = ENV[env_var]
    return value if value.present?

    if Rails.env.production?
      raise PqcError, "#{env_var} is required in production. Configure the #{description} environment variable."
    end

    warn "[PQC] #{env_var} not set — using development fallback for #{description}. DO NOT use in production."
    dev_fallback_key(env_var)
  end

  # Check if PQC key wrapping is enabled and configured
  def self.pqc_enabled?
    ENV["PQC_ENABLED"] == "true" &&
      ENV["PQC_PRIVATE_KEY_PATH"].present? &&
      ENV["PQC_WRAPPED_KEY"].present? &&
      ENV["PQC_KEM_CIPHERTEXT"].present?
  end

  # Generate a new ML-KEM-1024 keypair.
  # Returns the key object. Caller is responsible for secure storage.
  def self.generate_keypair
    raise PqcUnavailableError, "ML-KEM-1024 not available. Requires OpenSSL 3.5+" unless pqc_available?

    OpenSSL::PKey.generate_key(PQC_ALGORITHM)
  end

  # Write keypair to files with restricted permissions.
  # private_key_path gets mode 0600 (owner read/write only).
  def self.save_keypair(key, private_key_path:, public_key_path:)
    File.write(private_key_path, key.private_to_pem)
    File.chmod(0o600, private_key_path)

    File.write(public_key_path, key.public_to_pem)
    File.chmod(0o644, public_key_path)
  end

  # Wrap an existing primary key with PQC hybrid encryption.
  # Uses ML-KEM encapsulation to derive a shared secret, then
  # AES-256-GCM to encrypt the primary key.
  #
  # Returns { wrapped_key: base64, kem_ciphertext: base64 }
  def self.wrap_key(primary_key, public_key_pem)
    raise PqcUnavailableError, "ML-KEM-1024 not available" unless pqc_available?

    pub_key = OpenSSL::PKey.read(public_key_pem)
    ciphertext, shared_secret = pub_key.encapsulate

    # Derive a 256-bit wrapping key from the shared secret via SHA-256
    wrapping_key = OpenSSL::Digest::SHA256.digest(shared_secret)

    # AES-256-GCM encrypt the primary key
    encrypted = aes_gcm_encrypt(wrapping_key, primary_key.b)

    {
      wrapped_key: Base64.strict_encode64(encrypted),
      kem_ciphertext: Base64.strict_encode64(ciphertext)
    }
  end

  private

  # Generate a deterministic dev-only fallback key. NOT cryptographically
  # meaningful — exists solely to unblock local development without real
  # key material. Never called in production.
  def self.dev_fallback_key(scope)
    OpenSSL::HMAC.hexdigest("SHA256", "daria-dev-only-not-for-production", scope)
  end

  # Unwrap the primary key using ML-KEM decapsulation + AES-256-GCM
  def self.unwrap_primary_key
    raise PqcUnavailableError, "ML-KEM-1024 not available" unless pqc_available?

    private_key_path = ENV.fetch("PQC_PRIVATE_KEY_PATH")
    raise KeyUnwrapError, "Private key file not found: #{private_key_path}" unless File.exist?(private_key_path)

    priv_pem = File.read(private_key_path)
    priv_key = OpenSSL::PKey.read(priv_pem)

    ciphertext = Base64.strict_decode64(ENV.fetch("PQC_KEM_CIPHERTEXT"))
    wrapped_key = Base64.strict_decode64(ENV.fetch("PQC_WRAPPED_KEY"))

    # Decapsulate to recover the shared secret
    shared_secret = priv_key.decapsulate(ciphertext)

    # Derive the wrapping key
    wrapping_key = OpenSSL::Digest::SHA256.digest(shared_secret)

    # AES-256-GCM decrypt
    aes_gcm_decrypt(wrapping_key, wrapped_key)
  rescue PqcError
    raise
  rescue => e
    raise KeyUnwrapError, "Failed to unwrap primary key via PQC: #{e.message}"
  end

  # AES-256-GCM encrypt: returns iv + auth_tag + ciphertext
  def self.aes_gcm_encrypt(key, plaintext)
    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.encrypt
    cipher.key = key
    iv = cipher.random_iv

    ciphertext = cipher.update(plaintext) + cipher.final
    auth_tag = cipher.auth_tag

    iv + auth_tag + ciphertext
  end

  # AES-256-GCM decrypt: expects iv (12 bytes) + auth_tag (16 bytes) + ciphertext
  def self.aes_gcm_decrypt(key, data)
    iv = data[0, 12]
    auth_tag = data[12, 16]
    ciphertext = data[28..]

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    cipher.auth_tag = auth_tag

    cipher.update(ciphertext) + cipher.final
  end
end
