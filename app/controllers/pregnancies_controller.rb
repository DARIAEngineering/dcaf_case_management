class PregnanciesController < ApplicationController
  def index
  	@patient = Patient.new
    @pregnancies = @patient.pregnancies.build
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end
end
