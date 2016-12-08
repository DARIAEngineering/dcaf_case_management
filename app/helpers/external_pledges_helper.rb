module ExternalPledgesHelper
  def external_pledge_source_options
    ["Baltimore Abortion Fund", "Richmond Reproductive Freedom Project (RRFP)",
     "Blue Ridge Abortion Assistance Fund (BRAAF)", "Tiller Fund (NNAF)",
     "Carolina Abortion Fund", "Women's Medical Fund (Philadelphia)",
     "NYAAF (New York)", "Other funds (see notes)"]
  end

  def available_pledge_source_options_for(patient)
    used_sources = patient.external_pledges.map(&:source)
    (external_pledge_source_options - used_sources).unshift(nil)
  end
end
