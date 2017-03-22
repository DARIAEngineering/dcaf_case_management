class PledgeFormGenerator
  attr_reader :patient, :user

  def initialize(user, patient)
    @patient = patient
    @user = user
  end


  def patient_amount
    @patient.pregnancy.dcaf_soft_pledge + @patient.pregnancy.naf_pledge
  end

  # TODO when clinics actually exist instead of just name, do this
  def get_provider_address
    "Washington, District of Colombia"
  end

  def get_patient_provider_name
    patient.clinic_name
  end

  def get_patient_date
    patient.appointment_date.strftime "%B%e, %Y"
  end

  def get_patient_name
    patient.name
  end

  def get_user_name
    user.name
  end

  def generate_pledge_pdf
    pdf = Prawn::Document.new
    y_position = pdf.cursor
    pdf.bounding_box([0, y_position], :width => 200, :height => 100) do
      pdf.image "#{Rails.root.join("public", "dcaf_logo.png")}", position: :left, width: 200
    end
    pdf.bounding_box([250, y_position], :width => 200, :height => 100) do
      pdf.text "DC Abortion Fund"
      pdf.text "P.O. Box 65061"
      pdf.text "Tel: 202-452-7464"
      pdf.text "E-mail: info@dcabortionfund.org"
      pdf.text "Web: www.dcabortionfund.org"
    end
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    text_block = <<-TEXT
      We are writing to confirm that the DC Abortion Fund (DCAF) is pledging assistance in the amount of $#{patient_amount} toward the cost of abortion care for Patient #{get_patient_name} (D0-0000) on #{get_patient_date}. This payment will be remitted to the abortion provider, #{get_patient_provider_name} located in #{get_provider_address}.
        In order to receive payment, the abortion provider must mail a copy of this pledge form to:
        
        DCAF
        P.O. Box 65061
        Washington, D.C.  20035-5061
        
        Please know how much we appreciate the time and commitment it takes for clinics to coordinate funding for women in low-income situations.  If there is anything we can do to smooth the process, please let us know.  Again, thank you for making the freedom of choice a reality for all women.
    TEXT
    pdf.text text_block, align: :center, indent_paragraphs: 60
    next_y_position = pdf.cursor
    pdf.move_down 10
    pdf.bounding_box([0, next_y_position], :width => 200, :height => 50) do
      pdf.draw_text get_user_name, at: [10, 35]
      pdf.line [0,25], [225, 25]
      pdf.draw_text "Case Manager, DC Abortion Fund", at: [10,10]
    end
    pdf.bounding_box([250, next_y_position], :width => 200, :height => 50) do
      pdf.draw_text "February 26, 2017",at: [10,35]
      pdf.line [0,25], [225, 25]
      pdf.draw_text "Date", at: [10,10]
    end
    pdf.move_down 10
    pdf.bounding_box([50, pdf.cursor], width: 400, height: 150) do
      pdf.transparent(0.5) { pdf.stroke_bounds }
      pdf.text "This section to be filled out by clinic only (DCAF will only be liable for pledges billed within two weeks of procedure time)", align: :center, style: :italic
      pdf.move_down 10
      pdf.text "Patient's weeks of pregnancy at date of procedure:", align: :center, style: :bold
      pdf.move_down 10
      pdf.text "Date on which procedure was completed:", align: :center, style: :bold
      pdf.move_down 10
      pdf.text "Signature of Clinic Administrator:", align: :center, style: :bold
      pdf.move_down 10
      pdf.text "For billing questions only, please contact billing@dcabortionfund.org", align: :center, style: :italic
    end
    pdf.text "The information in this transmission is confidential.  If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution, or duplication of this communication is strictly prohibited. If you have received this transmission in error, please contact the sender at the information provided above, and destroy all copies.", style: :italic, align: :center
    return pdf
  end
end
