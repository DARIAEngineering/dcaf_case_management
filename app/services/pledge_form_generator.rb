class PledgeFormGenerator
  include ActionView::Helpers::NumberHelper # for currency formatting

  attr_reader :patient, :user, :case_manager_name, :fund

  def initialize(user, patient, case_manager_name, fund)
    @patient = patient
    @user = user
    @case_manager_name = case_manager_name
    @fund = fund
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
    if CONFIG_DATA.keys.include? @fund.pledge_generation_config
      pdf = generate_custom_pledge_pdf
    elsif @fund.pledge_generation_config == 'generic'
      pdf = generate_generic_pledge_pdf
    end
    pdf
  end

  def generate_custom_pledge_pdf
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

  def generate_generic_pledge_pdf
    pdf = Prawn::Document.new
    build_generic_header pdf
    build_generic_body pdf
    build_generic_signature pdf
    build_generic_remit pdf
    build_generic_footer pdf
    pdf
  end

  # Hacking some config into constants for convenience sake
  # Let a fund use one of these config sets via Fund.pledge_generation_config
  CONFIG_DATA = {
    'DCAF' => {
      addr: [
        'DC Abortion Fund',
        'P.O. Box 65061',
        'Washington, D.C. 20035-5061'
      ],
      width: 200,
      height: nil,
      contact_email: 'info@dcabortionfund.org',
      billing_email: 'billing@dcabortionfund.org',
      img: 'dcaf_logo.png'
    },
    'YHF' => {
      addr: [
        'The Yellowhammer Fund',
        'P.O. Box 1565',
        'Tuscaloosa, AL 35403'
      ],
      width: nil,
      height: 100,
      contact_email: 'info@yellowhammerfund.org',
      billing_email: 'billing@yellowhammer.org',
      img: 'yhf_logo.png'
    }
  }

  private

  def build_generic_header(pdf)
    y_position = pdf.cursor
    pdf.bounding_box([0, y_position], width: 200, height: 150) do
      pdf.image Rails.root.join("public", "daria_logo.png"),
                position: :left,
                width: 150,
                height: 150
    end

    pdf.bounding_box([250, y_position], width: 400, height: 150) do
      if Rails.env.development?
        pdf.text "SAMPLE - DO NOT USE", style: :bold
        pdf.move_down 10
      end

      pdf.text case_manager_name
      pdf.text @fund.full_name
      pdf.text "123 Fake Street" # TK Fund address L1
      pdf.text "Springfield, Ohiyamaude" # TK Fund address L2
      pdf.text "Tel: #{@fund.phone}"
      pdf.text "fund@example.com" # TK fund contact email
      pdf.text "Web: #{@fund.site_domain}"
    end

    pdf.stroke_horizontal_rule
    pdf.move_down 25
  end

  def build_generic_body(pdf)
    preamble_txt = <<-TEXT
      We are writing to confirm that the #{@fund.full_name} (#{@fund.name}) is pledging assistance in the amount of <b>#{patient_amount}</b> toward the cost of abortion care for <b>#{@patient.name} (#{@patient.identifier})</b> on <b>#{appointment_date}</b>. This payment will be remitted to the abortion provider, <b>#{@patient.clinic.name}</b> located in <b>#{@patient.clinic.display_location}</b>.

      In order to receive payment, the abortion provider must mail a copy of this pledge form to:

      #{@fund.full_name}
      ADDRESS1
      ADDRESS2

      Please know how much we appreciate the time and commitment it takes for clinics to coordinate funding for those in low-income situations. If there is anything we can do to smooth the process, please let us know.
    TEXT
    pdf.text preamble_txt, align: :left, inline_format: true
    pdf.move_down 10
  end

  def build_generic_signature(pdf)
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
    pdf.move_down 25
    pdf.stroke_horizontal_rule
    pdf.move_down 25
  end

  def build_generic_remit(pdf)
    pdf.text "<b><i>This section to be filled out by clinic only.</b></i>", align: :left, indent_paragraphs: 5, size: 8, inline_format: true
    pdf.move_down 10

    remit_txt = <<-TEXT
      Patient's weeks of pregnancy at date of procedure: _________________

      Date on which procedure was completed: _________________________

      Signature of Clinic Administrator: ________________________________
    TEXT
    pdf.bounding_box([25, pdf.cursor], width: 475, height: 100) do
      pdf.move_down 20
      pdf.transparent(0.5) { pdf.stroke_bounds }
      pdf.text remit_txt, align: :left, style: :bold, indent_paragraphs: 7
    end
    pdf.move_down 10
    pdf
  end

  def build_generic_footer(pdf)
    footer_txt = <<-TEXT
      The information in this transmission is confidential. If thereader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution, or duplication of this communication is strictly prohibited. If you have received this transmission in error, please contact the sender at the information provided above, and destroy all copies.
    TEXT
    pdf.text footer_txt, align: :left, inline_format: true
    pdf
  end

  def build_header(pdf)
    y_position = pdf.cursor
    pdf.bounding_box([0, y_position], width: 200, height: 100) do
      pdf.image Rails.root.join("public", CONFIG_DATA[@fund.pledge_generation_config][:img]),
                position: :left,
                width: CONFIG_DATA[@fund.pledge_generation_config][:width],
                height: CONFIG_DATA[@fund.pledge_generation_config][:height]
    end

    pdf.bounding_box([250, y_position], width: 400, height: 100) do
      pdf.text case_manager_name
      CONFIG_DATA[@fund.pledge_generation_config][:addr].each do |i|
        pdf.text i
      end
      pdf.text "Tel: #{@fund.phone}"
      pdf.text "E-mail: #{CONFIG_DATA[@fund.pledge_generation_config][:contact_email]}"
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
    info_block = "<b>#{CONFIG_DATA[@fund.pledge_generation_config][:addr].join("\n")}</b>"
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
      pdf.text "For billing questions only, please contact #{CONFIG_DATA[@fund.pledge_generation_config][:billing_email]}", align: :left, style: :italic, indent_paragraphs: 5
    end
  end

  def build_footer(pdf)
    pdf.text 'The information in this transmission is confidential.  If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution, or duplication of this communication is strictly prohibited. If you have received this transmission in error, please contact the sender at the information provided above, and destroy all copies.', style: :italic, align: :left, size: 8
  end
end
