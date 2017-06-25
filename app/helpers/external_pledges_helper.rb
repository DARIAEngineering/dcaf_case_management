# Functions to populate dropdowns related to external pledges.
module ExternalPledgesHelper
  def external_pledge_source_options
    Rails.configuration
         .external_pledges['funds']
         .reject { |fund| fund == FUND_FULL }
  end

  def available_pledge_source_options_for(patient)
    used_sources = patient.external_pledges.map(&:source)
    (external_pledge_source_options - used_sources).unshift(nil)
  end
end
