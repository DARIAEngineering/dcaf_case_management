module CasesHelper
  def weeks_options
    weeks = [[ 1, "1 Week" ]]
    (2..24).each do |i|
      weeks << [ i, "#{i} Weeks" ]
    end
    weeks
  end
end
