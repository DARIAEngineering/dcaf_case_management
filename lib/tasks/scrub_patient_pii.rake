namespace :security do
  desc 'Scrub PII fields from existing Patient PaperTrail versions'
  task scrub_patient_pii: :environment do
    count = PaperTrailVersion.scrub_patient_pii
    puts "#{Time.now} -- scrubbed PII from #{count} Patient version records"
  end
end
