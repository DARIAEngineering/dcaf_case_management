class PledgeFormGenerator
  include ActionView::Helpers::NumberHelper # for currency formatting

  attr_reader :patient, :user, :case_manager_name, :fund

  def initialize(user, patient, case_manager_name, fund)
    @patient = patient
    @user = user
    @case_manager_name = case_manager_name
    @fund = fund
    @config = fund.pledge_config
  end

  def patient_amount
    number_to_currency(@patient.fund_pledge, precision: 0)
  end

  def provider_address
    patient.clinic.display_location
  end

  def patient_provider_name
    patient.clinic.name
  end

  def appointment_date
    patient.appointment_date.strftime "%B %e, %Y"
  end

  def patient_name
    patient.name
  end

  def patient_identifier
    patient.identifier
  end

  def generate_pledge_pdf
    pdf = Prawn::Document.new

    build_header pdf
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    # main text portion
    build_patient_info_block pdf
    pdf.move_down 10

    build_fund_info_block pdf
    pdf.move_down 10

    build_thank_you_text_block pdf
    pdf.move_down 10

    # signature and remit portion
    build_signature_block pdf
    pdf.move_down 10

    # remit portion
    build_remit_block pdf
    pdf.move_down 10

    # footer
    build_footer pdf

    # slam dunk
    pdf
  end

  private

  def build_header(pdf)
    y_position = pdf.cursor
    pdf.bounding_box([0, y_position], width: 200, height: 100) do
      # Use a logo if provided
      if @config.logo_url
        pdf.image Rails.root.join("public", @config.logo_url),
                  position: :left,
                  width: @config.logo_width,
                  height: @config.logo_height
      # Otherwise, use stock DARIA services logo
      else
        pdf.image Rails.root.join("public", "daria-logo.png"),
                  position: :left,
                  width: 75,
                  height: 75

      end
    end

    pdf.bounding_box([250, y_position], width: 400, height: 100) do
      pdf.text case_manager_name
      pdf.text @fund.full_name
      pdf.text @config.address1
      pdf.text @config.address2
      pdf.text "Tel: #{@config.phone || @fund.phone}"
      pdf.text "E-mail: #{@config.contact_email}"
      pdf.text "Web: #{@fund.site_domain}"
    end
  end

  def build_patient_info_block(pdf)
    patient_info_block = <<-TEXT
      We are writing to confirm that the #{@fund.full_name} (#{@fund.name}) is pledging assistance in the amount of <b>#{patient_amount}</b> toward the cost of abortion care for <b>#{patient_name} (#{patient_identifier})</b> on <b>#{appointment_date}</b>. This payment will be remitted to the abortion provider, <b>#{patient_provider_name}</b> located in <b>#{provider_address}</b>.

      In order to receive payment, the abortion provider must mail a copy of this pledge form to:
    TEXT
    pdf.text patient_info_block, align: :left, inline_format: true
  end

  def build_fund_info_block(pdf)
    info_block = "<b>#{@fund.full_name}\n#{@config.address1}\n#{@config.address2}</b>"
    pdf.text info_block, align: :center, inline_format: true
  end

  def build_thank_you_text_block(pdf)
    thank_you_text = <<-TEXT
      Please know how much we appreciate the time and commitment it takes for clinics to coordinate funding for women in low-income situations.  If there is anything we can do to smooth the process, please let us know.
    TEXT
    pdf.text thank_you_text, align: :left
  end

  def build_signature_block(pdf)
    now_as_date = Time.zone.now.strftime('%b %d, %Y')

    next_y_position = pdf.cursor
    pdf.move_down 10
    pdf.bounding_box([0, next_y_position], width: 200, height: 50) do
      pdf.draw_text case_manager_name, at: [10, 35]
      pdf.line [0, 25], [225, 25]
      pdf.draw_text "Case Manager, #{@fund.full_name}", at: [10, 10]
    end
    pdf.bounding_box([250, next_y_position], width: 200, height: 50) do
      pdf.draw_text now_as_date, at: [10, 35]
      pdf.line [0, 25], [225, 25]
      pdf.draw_text 'Date', at: [10, 10]
    end
  end

  def build_remit_block(pdf)
    pdf.bounding_box([25, pdf.cursor], width: 475, height: 130) do
      pdf.transparent(0.5) { pdf.stroke_bounds }
      pdf.move_down 10
      pdf.text "<b><i>This section to be filled out by clinic only (#{@fund.name} will only be liable for pledges billed within two months of procedure date).</i></b>", align: :left, indent_paragraphs: 5, size: 8, inline_format: true
      pdf.move_down 10
      pdf.text "Patient's weeks of pregnancy at date of procedure: _________________", align: :left, style: :bold, indent_paragraphs: 5
      pdf.move_down 10
      pdf.text 'Date on which procedure was completed: _________________________', align: :left, style: :bold, indent_paragraphs: 5
      pdf.move_down 10
      pdf.text 'Signature of Clinic Administrator: ________________________________', align: :left, style: :bold, indent_paragraphs: 5
      pdf.move_down 10
      pdf.text "For billing questions only, please contact #{@config.billing_email}", align: :left, style: :italic, indent_paragraphs: 5
    end
  end

  def build_footer(pdf)
    pdf.text 'The information in this transmission is confidential.  If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution, or duplication of this communication is strictly prohibited. If you have received this transmission in error, please contact the sender at the information provided above, and destroy all copies.', style: :italic, align: :left, size: 8
  end
end
