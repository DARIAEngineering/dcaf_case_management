class ArchivedPatientsController < ApplicationController
  before_action :redirect_unless_has_data_access, only: [:index, :show, :destroy]
  before_action :set_archived_patient, only: [:show, :destroy]

  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { redirect_to root_path }


  # GET /archived_patients
  def index
    respond_to do |format|
      format.csv do
        render_csv
      end
    end
  end


  # GET /archived_patients/1
  def show
  end

  # TODO - not needed?
  # GET /archived_patients/new
  def new
    @archived_patient = ArchivedPatient.new
  end

  # should be expecting to be handed an existing patient TODO
  # POST /archived_patients
  def create
    @archived_patient = ArchivedPatient.new archived_patient_params

    if @archived_patient.save
       flash[:notice] = 'A patient has been successfully archived'
    else
       flash[:alert] = "Errors prevented this patient from being archived: #{archived_patient.errors.full_messages.to_sentence}"
    end

    current_user.add_patient patient
    redirect_to root_path
  end

  # DELETE /archived_patients/1
  def destroy
    @archived_patient.destroy
    respond_to do |format|
      format.html { redirect_to archived_patients_url, notice: 'Archived patient was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archived_patient
      @archived_patient = ArchivedPatient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # Should only need a patient id? TODO
    def archived_patient_params
      params.require(:archived_patient).permit(:patient_id)
    end

    def render_csv
      now = Time.zone.now.strftime('%Y%m%d')
      csv_filename = "patient_data_export_#{now}.csv"
      set_headers(csv_filename)

      response.status = 200

      self.response_body = Patient.to_csv
    end

    def set_headers(filename)
      headers["Content-Type"] = "text/csv"
      headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
      headers['X-Accel-Buffering'] = 'no'
      headers["Cache-Control"] = "no-cache"
      headers.delete("Content-Length")
    end
end
