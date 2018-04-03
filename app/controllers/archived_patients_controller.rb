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
      format.html do
        @archived_patients = ArchivedPatient.all
      end
    end
  end


  # GET /archived_patients/1
  def show
    @archived_patient
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
      csv_filename = "archived_patient_data_export_#{now}.csv"
      set_headers(csv_filename)

      response.status = 200

      self.response_body = ArchivedPatient.to_csv
    end

    def set_headers(filename)
      headers["Content-Type"] = "text/csv"
      headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
      headers['X-Accel-Buffering'] = 'no'
      headers["Cache-Control"] = "no-cache"
      headers.delete("Content-Length")
    end

    def to_csv
      #not yet implemented
      # TODO connect to exportable concern
    end
end
