module Pledgeable
  extend ActiveSupport::Concern

  def pledge_info_present?
    pledge_info_presence
    errors.messages.present?
  end

  def pledge_info_errors
    errors.messages.values.flatten.uniq
  end
end
