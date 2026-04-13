desc 'PQC key management tasks'
namespace :pqc do
  desc 'Generate a new ML-KEM-1024 keypair for PQC hybrid key wrapping'
  task generate_keypair: :environment do
    unless PqcKeyManager.pqc_available?
      abort "ERROR: ML-KEM-1024 not available. Requires OpenSSL 3.5+ " \
            "(see PR #3531 upgrade/openssl-3.5.5)."
    end

    key = PqcKeyManager.generate_keypair

    priv_path = ENV.fetch("PQC_PRIVATE_KEY_PATH", "config/credentials/pqc_private.pem")
    pub_path = ENV.fetch("PQC_PUBLIC_KEY_PATH", "config/credentials/pqc_public.pem")

    FileUtils.mkdir_p(File.dirname(priv_path))
    PqcKeyManager.save_keypair(key, private_key_path: priv_path, public_key_path: pub_path)

    puts "ML-KEM-1024 Keypair Generated"
    puts "=============================="
    puts ""
    puts "Private key: #{priv_path} (mode 0600)"
    puts "Public key:  #{pub_path}"
    puts ""
    puts "Set the environment variable:"
    puts "  PQC_PRIVATE_KEY_PATH=#{priv_path}"
    puts ""
    puts "IMPORTANT: Back up the private key securely and add it to .gitignore."
    puts "If lost, PQC-wrapped keys cannot be recovered."
  end

  desc 'Wrap the current primary encryption key with PQC hybrid encryption'
  task wrap_key: :environment do
    unless PqcKeyManager.pqc_available?
      abort "ERROR: ML-KEM-1024 not available. Requires OpenSSL 3.5+."
    end

    pub_path = ENV.fetch("PQC_PUBLIC_KEY_PATH") do
      abort "ERROR: Set PQC_PUBLIC_KEY_PATH env var. Run `rake pqc:generate_keypair` first."
    end

    unless File.exist?(pub_path)
      abort "ERROR: Public key file not found: #{pub_path}"
    end

    primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY") do
      abort "ERROR: ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY not set."
    end

    public_key_pem = File.read(pub_path)
    result = PqcKeyManager.wrap_key(primary_key, public_key_pem)

    puts "Primary Key Wrapped with ML-KEM-1024 + AES-256-GCM"
    puts "===================================================="
    puts ""
    puts "Add these to your environment:"
    puts ""
    puts "PQC_ENABLED=true"
    puts "PQC_WRAPPED_KEY=#{result[:wrapped_key]}"
    puts "PQC_KEM_CIPHERTEXT=#{result[:kem_ciphertext]}"
    puts ""
    puts "You can now remove ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY from your"
    puts "environment (keep a backup). The key will be unwrapped at boot time"
    puts "using PQC_PRIVATE_KEY_PATH + PQC_WRAPPED_KEY + PQC_KEM_CIPHERTEXT."
  end
end
