class PledgeFormGenerator
  attr_reader :patient, :user

  def initialize(user, patient)
    @patient = patient
    @user = user
  end

  def patient_amount
    @patient.pregnancy.dcaf_soft_pledge
  end

  # TODO when clinics actually exist instead of just name, do this
  def provider_address
    'Washington, District of Colombia'
  end

  def patient_provider_name
    patient.clinic_name
  end

  def patient_date
    patient.appointment_date.strftime "%B%e, %Y"
  end

  def patient_name
    patient.name
  end

  def user_name
    user.name
  end

  def generate_pledge_pdf
    pdf = Prawn::Document.new

    # header
    y_position = pdf.cursor
    pdf.bounding_box([0, y_position], width: 200, height: 100) do
      pdf.image '#{Rails.root.join("public", "dcaf_logo.png")}',
                position: :left, width: 200
    end
    pdf.bounding_box([250, y_position], width: 200, height: 100) do
      pdf.text 'DC Abortion Fund'
      pdf.text 'P.O. Box 65061'
      pdf.text 'Tel: 202-452-7464'
      pdf.text 'E-mail: info@dcabortionfund.org'
      pdf.text 'Web: www.dcabortionfund.org'
    end
    pdf.stroke_horizontal_rule

    # main text with patient info
    pdf.move_down 10
    patient_info_block = <<-TEXT
      We are writing to confirm that the DC Abortion Fund (DCAF) is pledging assistance in the amount of $#{patient_amount} toward the cost of abortion care for Patient #{patient_name} (D0-0000) on #{patient_date}. This payment will be remitted to the abortion provider, #{patient_provider_name} located in #{provider_address}.

      In order to receive payment, the abortion provider must mail a copy of this pledge form to:
    TEXT
    pdf.text patient_info_block, align: :left
    pdf.move_down 10

    dcaf_info_block = <<-TEXT
      DCAF
      P.O. Box 65061
      Washington, D.C.  20035-5061
    TEXT
    pdf.text dcaf_info_block, align: :center
    pdf.move_down 10

    thank_you_text = <<-TEXT
      Please know how much we appreciate the time and commitment it takes for clinics to coordinate funding for women in low-income situations.  If there is anything we can do to smooth the process, please let us know.  Again, thank you for making the freedom of choice a reality for all women.
    TEXT
    pdf.text thank_you_text, align: :left
    pdf.move_down 10

    # signature portion
    next_y_position = pdf.cursor
    pdf.move_down 10
    pdf.bounding_box([0, next_y_position], width: 200, height: 50) do
      pdf.draw_text user_name, at: [10, 35]
      pdf.line [0, 25], [225, 25]
      pdf.draw_text 'Case Manager, DC Abortion Fund', at: [10, 10]
    end
    pdf.bounding_box([250, next_y_position], width: 200, height: 50) do
      pdf.draw_text 'February 26, 2017', at: [10, 35]
      pdf.line [0, 25], [225, 25]
      pdf.draw_text 'Date', at: [10, 10]
    end
    pdf.move_down 10

    # remit portion
    pdf.bounding_box([25, pdf.cursor], width: 475, height: 130) do
      pdf.transparent(0.5) { pdf.stroke_bounds }
      pdf.move_down 10
      pdf.text '<b><i>This section to be filled out by clinic only (DCAF will only be liable for pledges billed within two months of procedure date).</i></b>', align: :left, indent_paragraphs: 5, size: 8, inline_format: true
      pdf.move_down 10
      pdf.text "Patient's weeks of pregnancy at date of procedure: _________________", align: :left, style: :bold, indent_paragraphs: 5
      pdf.move_down 10
      pdf.text 'Date on which procedure was completed: _________________________', align: :left, style: :bold, indent_paragraphs: 5
      pdf.move_down 10
      pdf.text 'Signature of Clinic Administrator: ________________________________', align: :left, style: :bold, indent_paragraphs: 5
      pdf.move_down 10
      pdf.text 'For billing questions only, please contact billing@dcabortionfund.org', align: :left, style: :italic, indent_paragraphs: 5
    end
    pdf.move_down 10

    # footer
    pdf.text 'The information in this transmission is confidential.  If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution, or duplication of this communication is strictly prohibited. If you have received this transmission in error, please contact the sender at the information provided above, and destroy all copies.', style: :italic, align: :left, size: 8

    # slam dunk
    return pdf
  end
end
