namespace :note do
  desc "update notes to be encrypted with ActiveRecord encryption"
  task encrypt_full_text: :environment do
    Note.all.find_each do |note|
      note.encrypt
    end
  end
end
