class PatientsController < ApplicationController


	def new
		@patient = Patient.new
	end

	def create
		@patient = Patient.new(patient_params)

		if @patient.save
			redirect_to root_path
		else
			render 'New'
		end
	end

	private

	def patient_params
		params.require(:patient).permit(:name, :primary_phone, :secondary_phone)
	end

end