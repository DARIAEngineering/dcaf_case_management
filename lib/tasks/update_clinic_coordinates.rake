namespace :clinics do
  desc "Mass-update all lat-lng coordinates for clinic addresses"
  task update_coordinates: :environment do
    Clinic.all.each do |clinic|
      clinic.update_coordinates
    end
  end
end
