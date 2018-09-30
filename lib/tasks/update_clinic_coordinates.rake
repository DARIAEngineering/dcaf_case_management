namespace :clinics do
  desc "Mass-update all lat-lng coordinates for clinic addresses"
  task update_coordinates: :environment do
    raise 'Please set an env var GOOGLE_GEO_API_KEY before you do this' unless ENV['GOOGLE_GEO_API_KEY']
    Clinic.all.each do |clinic|
      clinic.update_coordinates
    end
  end
end
