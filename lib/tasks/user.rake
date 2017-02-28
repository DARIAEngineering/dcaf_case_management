task do_shit: :environment do
  Prawn::Document.generate("hello.pdf") do
    y_position = cursor
    bounding_box([0, y_position], :width => 200, :height => 100) do
      image "#{Rails.root.join("public", "dcaf_logo.png")}", position: :left, width: 200
    end
    bounding_box([250, y_position], :width => 200, :height => 100) do
      text "DC Abortion Fund"
      text "P.O. Box 65061"
      text "Tel: 202-452-7464"
      text "E-mail: info@dcabortionfund.org"
      text "Web: www.dcabortionfund.org"
    end
    text_block = <<-TEXT
      We are writing to confirm that the DC Abortion Fund (DCAF) is pledging assistance in the amount of $xxx toward the cost of abortion care for Patient XXXX (D0-0000) on June 4, 2016. This payment will be remitted to the abortion provider, Washington Hospital Center located in Washington, District of Columbia.
        In order to receive payment, the abortion provider must mail a copy of this pledge form to:
        
        DCAF
        P.O. Box 65061
        Washington, D.C.  20035-5061
        
        Please know how much we appreciate the time and commitment it takes for clinics to coordinate funding for women in low-income situations.  If there is anything we can do to smooth the process, please let us know.  Again, thank you for making the freedom of choice a reality for all women.
    TEXT
    text text_block, align: :center, indent_paragraphs: 60
    next_y_position = cursor
    bounding_box([0, next_y_position], :width => 200, :height => 50) do
      text "(Your Name Here)"
      text "Case Manager, DC Abortion Fund"
    end
    bounding_box([250, next_y_position], :width => 200, :height => 50) do
      text "February 26, 2017"
      text "Date"
    end
    bounding_box([50, cursor], width: 400, height: 200) do
      transparent(0.5) { stroke_bounds }
      text "This section to be filled out by clinic only (DCAF will only be liable for pledges billed within two weeks of procedure time)", align: :center, style: :italic
      text "Patient's weeks of pregnancy at date of procedure:", align: :center, style: :bold
      text "Date on which procedure was completed:", align: :center, style: :bold
      text "Signature of Clinic Administrator:", align: :center, style: :bold
      text "For billing questions only, please contact billing@dcabortionfund.org", align: :center, style: :italic
    end
    text "The information in this transmission is confidential.  If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution, or duplication of this communication is strictly prohibited. If you have received this transmission in error, please contact the sender at the information provided above, and destroy all copies.", style: :italic, align: :center

  end
end

namespace :user do
  desc "update role field production data"
  task update_role: :environment do
    User.all.each do |user|
      enum_role = check_role(user.role)
      user.update(role: enum_role)
    end

    puts 'User role updated'
  end

private
  def check_role(role)
    case role
    when 'admin'
      1
    else
      0
    end
  end
end
