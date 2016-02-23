# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Call.destroy_all
Pregnancy.destroy_all
Patient.destroy_all

10.times do |i|
  Patient.create({name: "Patient #{i}", primary_phone: "123-123-123#{i}"})
end

patients = Patient.all

patients.each do |patient|
  if(patient.name[-1, 1].to_i.even?) then
    flag = true
  else
    flag = false
  end
  patient.cases.create({last_menstrual_period_time: DateTime.new(2016,1,1), urgent_flag: flag})
end
