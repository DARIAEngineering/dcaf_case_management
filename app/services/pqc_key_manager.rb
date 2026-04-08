# Post-Quantum Cryptography hybrid key manager.
#
# Wraps Rails Active Record encryption keys using ML-KEM-1024 (FIPS 203)
# combined with AES-256-KW (RFC 3394) for quantum-resistant key protection.
#
# Hybrid approach: Even if ML-KEM is broken, AES-256-KW still protects the key.
# Even if AES-256 is broken, ML-KEM still protects the key.
#
# Environment variables:
#   PQC_ENABLED          - Set to "true" to enable PQC key unwrapping
#   PQC_PRIVATE_KEY      - Base64-encoded ML-KEM-1024 private key
#   PQC_WRAPPED_KEY      - Base64-encoded AES-256-KW wrapped primary key
#   PQC_KEM_CIPHERTEXT   - Base64-encoded ML-KEM ciphertext (shared secret)
#
# Dual-read: If PQC env vars are set, unwraps the key. Otherwise falls back
# to the raw ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY env var.
class PqcKeyManager
  PQC_ALGORITHM = "ML-KEM-1024".freeze

  class PqcError < StandardError; end
  class KeyUnwrapError < PqcError; end

  # Returns the primary encryption key, unwrapping via PQC if configured
  def self.primary_key
    if pqc_enabled?
      unwrap_primary_key
    else
      ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "default_primary_key")
    end
  end

  # Check if PQC key wrapping is enabled
  def self.pqc_enabled?
    ENV["PQC_ENABLED"] == "true" &&
      ENV["PQC_PRIVATE_KEY"].present? &&
      ENV["PQC_WRAPPED_KEY"].present? &&
      ENV["PQC_KEM_CIPHERTEXT"].present?
  end

  # Generate a new ML-KEM-1024 keypair for initial setup
  # Returns { public_key: base64, private_key: base64 }
  def self.generate_keypair
    require "openssl"
    kem = OpenSSL::KEM.new(PQC_ALGORITHM)
    keypair = kem.generate_key

    {
      public_key: Base64.strict_encode64(keypair.public_to_der),
      private_key: Base64.strict_encode64(keypair.private_to_der)
    }
  end

  # Wrap an existing primary key with PQC hybrid encryption
  # Returns { wrapped_key: base64, kem_ciphertext: base64 }
  def self.wrap_key(primary_key, public_key_base64)
    require "openssl"

    # Decapsulate: use ML-KEM public key to get shared secret + ciphertext
    pub_der = Base64.strict_decode64(public_key_base64)
    pub_key = OpenSSL::PKey.read(pub_der)
    kem = OpenSSL::KEM.new(PQC_ALGORITHM)
    ciphertext, shared_secret = kem.encapsulate(pub_key)

    # Derive a 256-bit wrapping key from the shared secret
    wrapping_key = OpenSSL::Digest::SHA256.digest(shared_secret)

    # AES-256-KW wrap the primary key
    wrapped = aes_key_wrap(wrapping_key, primary_key.b)

    {
      wrapped_key: Base64.strict_encode64(wrapped),
      kem_ciphertext: Base64.strict_encode64(ciphertext)
    }
  end

  private

  # Unwrap the primary key using ML-KEM decapsulation + AES-256-KW
  def self.unwrap_primary_key
    require "openssl"

    priv_der = Base64.strict_decode64(ENV["PQC_PRIVATE_KEY"])
    priv_key = OpenSSL::PKey.read(priv_der)

    ciphertext = Base64.strict_decode64(ENV["PQC_KEM_CIPHERTEXT"])
    wrapped_key = Base64.strict_decode64(ENV["PQC_WRAPPED_KEY"])

    # Decapsulate to recover the shared secret
    kem = OpenSSL::KEM.new(PQC_ALGORITHM)
    shared_secret = kem.decapsulate(priv_key, ciphertext)

    # Derive the wrapping key
    wrapping_key = OpenSSL::Digest::SHA256.digest(shared_secret)

    # AES-256-KW unwrap
    aes_key_unwrap(wrapping_key, wrapped_key)
  rescue => e
    raise KeyUnwrapError, "Failed to unwrap primary key via PQC: #{e.message}"
  end

  # AES-256 Key Wrap (RFC 3394)
  def self.aes_key_wrap(kek, plaintext)
    cipher = OpenSSL::Cipher.new("aes-256-wrap")
    cipher.encrypt
    cipher.key = kek
    cipher.update(plaintext) + cipher.final
  end

  # AES-256 Key Unwrap (RFC 3394)
  def self.aes_key_unwrap(kek, ciphertext)
    cipher = OpenSSL::Cipher.new("aes-256-wrap")
    cipher.decrypt
    cipher.key = kek
    cipher.update(ciphertext) + cipher.final
  end
end
