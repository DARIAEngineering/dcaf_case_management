# Functions to populate dropdowns related to external pledges.
module ExternalPledgesHelper
  def external_funds
    Config.find_or_create_by(config_key: 'external_pledge_source').options
  end

  def solidarity_leads
    current_fund = [
      [current_tenant.name, nil]
    ]
    external_funds.push(*current_fund)
  end

  def external_pledge_source_options
    standard_options = [
      [ t('external_pledge.sources.clinic_discount'), 'Clinic discount'],
      [ t('external_pledge.sources.other_funds'), 'Other funds (see notes)']
    ]
    unless Config.hide_standard_dropdown?
      external_funds.push(*standard_options)
    end

    external_funds.uniq
  end

  def available_pledge_source_options_for(patient)
    used_sources = patient.external_pledges.map(&:source)
    (external_pledge_source_options - used_sources).unshift(nil)
  end
end
