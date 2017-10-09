# Functions primarily related to accountant billing view
module AccountantsHelper

  def patientInitials(patient)
    nameArr=patient.name.split(" ")
    initial = ''
    for i in nameArr
      initial.concat(i[0])
    end
    return initial
  end

end
