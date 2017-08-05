# Functions to populate dropdowns related to external pledges.
module ExternalPledgesHelper
  def external_pledge_source_options
    standard_options = ['Clinic discount', 'Other fund (see notes)']
    [nil].push(*Config.find_or_create_by(config_key: 'external_pledge_source').options)
         .push(*standard_options)
         .uniq
  end

  def available_pledge_source_options_for(patient)
    used_sources = patient.external_pledges.map(&:source)
    (external_pledge_source_options - used_sources)
  end
end
