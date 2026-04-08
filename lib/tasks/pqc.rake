desc 'PQC key management tasks'
namespace :pqc do
  desc 'Generate a new ML-KEM-1024 keypair for PQC hybrid key wrapping'
  task generate_keypair: :environment do
    keypair = PqcKeyManager.generate_keypair
    puts "ML-KEM-1024 Keypair Generated"
    puts "=============================="
    puts ""
    puts "Add these to your environment (e.g., Heroku config vars):"
    puts ""
    puts "PQC_PRIVATE_KEY=#{keypair[:private_key]}"
    puts ""
    puts "Store the public key securely for wrapping operations:"
    puts "PQC_PUBLIC_KEY=#{keypair[:public_key]}"
    puts ""
    puts "IMPORTANT: Back up the private key securely. If lost, encrypted data"
    puts "cannot be recovered (unless you still have the raw primary key)."
  end

  desc 'Wrap the current primary encryption key with PQC hybrid encryption'
  task wrap_key: :environment do
    public_key = ENV.fetch("PQC_PUBLIC_KEY") do
      abort "ERROR: Set PQC_PUBLIC_KEY env var first. Run `rake pqc:generate_keypair` to create one."
    end

    primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY") do
      abort "ERROR: ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY not set."
    end

    result = PqcKeyManager.wrap_key(primary_key, public_key)
    puts "Primary Key Wrapped with ML-KEM-1024 + AES-256-KW"
    puts "==================================================="
    puts ""
    puts "Add these to your environment:"
    puts ""
    puts "PQC_ENABLED=true"
    puts "PQC_WRAPPED_KEY=#{result[:wrapped_key]}"
    puts "PQC_KEM_CIPHERTEXT=#{result[:kem_ciphertext]}"
    puts ""
    puts "You can now remove ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY from your"
    puts "environment (keep a backup). The key will be unwrapped at boot time"
    puts "using PQC_PRIVATE_KEY + PQC_WRAPPED_KEY + PQC_KEM_CIPHERTEXT."
  end
end
