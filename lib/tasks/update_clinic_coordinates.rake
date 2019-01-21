namespace :clinics do
  desc "Mass-update all lat-lng coordinates for clinic addresses"
  task update_coordinates: :environment do
    Clinic.update_all_coordinates
  end
end
