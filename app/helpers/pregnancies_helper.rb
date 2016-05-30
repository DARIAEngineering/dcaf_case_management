module PregnanciesHelper
  def weeks_options
    weeks = [['1 Week', 1]]
    (2..24).each do |i|
      weeks << ["#{i} Weeks", i]
    end
    weeks
  end
end
